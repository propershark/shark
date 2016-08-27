module Shark
  describe ObjectManager, 'class' do
    subject { ObjectManager }

    it 'is configurable' do
      expect(subject.ancestors).to include(Configurable)
      expect(subject).to respond_to(:configuration)
      expect(subject.configuration).to be_a(Configuration)
    end

    context '::configuration' do
      subject { ObjectManager.configuration }
      it 'is valid according to the schema' do
        expect(subject.validate!).to be_truthy
      end

      it 'is an ObjectManagerConfiguration' do
        expect(subject).to be_a(ObjectManagerConfiguration)
      end

      it 'covers all expected options' do
        expect(subject).to respond_to(:object_type)
        expect(subject).to respond_to(:update_frequency)
        expect(subject).to respond_to(:sources)
      end
    end
  end


  describe ObjectManager do
    require './source.rb'
    before :all do
      TestObject = Class.new(Object) do
        attribute :name
        primary_attribute :name
      end
      @object1 = TestObject.new(name: 'object1')
      @object2 = TestObject.new(name: 'object2')

      MockSource = Class.new(Source::NormalSource) do
        def self.objects; @objects ||= []; end
        def initialize config={}
          @update_count = 0
        end
        def refresh; end
        def update manager
          # Toggle activation of `object1` and `object2` on every cycle.
          self.class.objects.each do |obj|
            manager.activate(obj) if @update_count.even?
          end
          @update_count += 1
        end
      end
      MockSource.objects.concat([@object1, @object2])

      Source.register_source(:test_source1, TestObject, MockSource)
      @config = ObjectManager.configure do |c|
        c.object_type       = TestObject
        c.update_frequency  = '2s'
        c.source_from :test_source1
      end
    end

    let(:agency)  { Shark::Agency.new }
    subject { ObjectManager.new('test_manager', agency) }


    it 'is configurable' do
      expect(subject).to respond_to(:configuration)
      expect(subject.configuration).to be_a(Configuration)
    end


    context '#initialize' do
      it 'sets name and agency from the given arguments' do
        expect(subject.name).to eq('test_manager')
        expect(subject.agency).to be agency
      end

      it 'passes a given block to #configure' do
        object = ObjectManager.new('test_manager', agency) do |config|
          config.update_frequency = '1s'
        end
        expect(object.configuration.update_frequency).to eq('1s')
      end

      it 'reads values from its configuration' do
        object = ObjectManager.new('test_manager', agency)
        expect(object.klass).to eq(@config.object_type)
        expect(object.update_frequency).to eq(@config.update_frequency)
        expect(object.sources.size).to eq(1)
      end

      it 'creates Source instances for each source in the configuration' do
        object = ObjectManager.new('test_manager', agency)
      end
    end

    context '#activate' do
      it 'adds object identifiers to the set of active objects' do
        subject.activate(@object1)
        subject.activate(@object2)
        expect(subject.active_objects).to include(@object1.identifier, @object2.identifier)
      end

      it 'adds active objects to the current storage adapter' do
        subject.activate(@object1)
        expect(subject.storage.find(@object1.identifier)).to be(@object1)
      end

      it 'only adds one instance of an object to the set of active objects' do
        subject.activate(@object1)
        subject.activate(@object1)
        expect(subject.active_objects).to contain_exactly(@object1.identifier)
      end
    end

    context '#deactivate' do
      before :each do
        subject.activate(@object1)
        subject.activate(@object2)
      end

      it 'removes object identifiers from the set of active objects' do
        subject.deactivate(@object1)
        expect(subject.active_objects).to_not include(@object1.identifier)
      end

      it 'only removes the given object' do
        subject.deactivate(@object1)
        expect(subject.active_objects).to include(@object2.identifier)
      end

      it 'does not remove objects from the current storage adapter' do
        subject.deactivate(@object1)
        expect(subject.storage.find(@object1.identifier)).to be(@object1)
      end

      it 'does nothing when the object has already been deactivated' do
        subject.deactivate(@object1)
        subject.deactivate(@object1)
      end
    end

    context '#deactivate_all' do
      before :each do
        subject.activate(@object1)
        subject.activate(@object2)
      end

      it 'removes all objects from the set of active objects' do
        subject.deactivate_all
        expect(subject.active_objects).to be_empty
      end

      it 'does not remove objects from the current storage adapter' do
        subject.deactivate_all
        expect(subject.storage.find(@object1.identifier)).to be(@object1)
        expect(subject.storage.find(@object2.identifier)).to be(@object2)
      end
    end

    context '#remove' do
      before :each do
        subject.activate(@object1)
        subject.activate(@object2)
      end

      it 'removes object identifiers from the set of active objects' do
        subject.remove(@object1)
        expect(subject.active_objects).to_not include(@object1.identifier)
      end

      it 'removes objects from the storage adapter' do
        subject.remove(@object1)
        expect(subject.storage.find(@object1)).to be_nil
      end

      it 'only removes the given object' do
        subject.remove(@object1)
        expect(subject.active_objects).to include(@object2.identifier)
        expect(subject.storage.find(@object2.identifier)).to be(@object2)
      end
    end

    context '#find' do
      before :each do
        subject.activate(@object1)
        subject.activate(@object2)
      end

      it 'returns objects that already exist in the storage adapter' do
        expect(subject.find(@object1.identifier)).to be(@object1)
      end

      it 'looks up identifiers in the current storage adapter' do
        storage_double = double(Storage)
        expect(storage_double).to receive(:find).with(@object1.identifier)
        subject.storage = storage_double
        subject.find(@object1.identifier)
      end

      it 'returns nil if an object is not in the current storage adapter' do
        expect(subject.find('not.an.identifier')).to be_nil
      end
    end

    context '#find_or_new' do
      before :each do
        subject.activate(@object1)
        subject.activate(@object2)
      end

      it 'returns objects that already exist in the storage adapter' do
        expect(subject.find(@object1.identifier)).to be(@object1)
      end

      it 'looks up identifiers in the current storage adapter' do
        storage_double = double(Storage)
        expect(storage_double).to receive(:find).with(@object1.identifier)
        subject.storage = storage_double
        subject.find(@object1.identifier)
      end

      it 'returns a new instance of `klass` if the object is not in the storage adapter' do
        subject.klass = TestObject
        expect(subject.find_or_new('not.an.identifier')).to be_a(subject.klass)
      end
    end

    context '#each' do
      before :each do
        subject.activate(@object1)
        subject.activate(@object2)
      end

      it 'calls the given block for each currently-active object' do
        args_passed = []
        subject.each{ |arg| args_passed << arg }
        expect(args_passed).to include(@object1.identifier, @object2.identifier)
      end

      it 'does not call the given block when no objects are active' do
        subject.deactivate_all
        args_passed = []
        subject.each{ |arg| args_passed << arg }
        expect(args_passed).to be_empty
      end
    end

    context 'update' do
      before :each do
        agency_double = double()
        @events_sent = []
        allow(agency_double).to receive(:call){ |event| @events_sent << [event.topic, event.type] }
        subject.agency = agency_double
      end

      it 'calls `refresh` and `update` for each of its Source instances' do
        subject.sources.each do |source|
          expect(source).to receive(:refresh)
          expect(source).to receive(:update).with(subject)
        end
        subject.update
      end

      it 'emits `activate` events when objects are activated' do
        subject.update
        expect(@events_sent).to include([@object1.identifier, :activate])
        expect(@events_sent).to include([@object2.identifier, :activate])
      end

      it 'emits `update` events for all active objects' do
        subject.update
        expect(@events_sent).to include([@object1.identifier, :update])
        expect(@events_sent).to include([@object2.identifier, :update])
      end

      it 'emits `deactivate` events when objects are deactivated' do
        # One update activates the objects. The second deactivates them.
        subject.update
        subject.update
        expect(@events_sent).to include([@object1.identifier, :deactivate])
        expect(@events_sent).to include([@object2.identifier, :deactivate])
      end

      it 'does not emit `update` events for deactivated objects' do
        subject.update
        @events_sent.clear
        subject.update
        expect(@events_sent).to_not include([@object1.identifier, :update])
        expect(@events_sent).to_not include([@object2.identifier, :update])
      end
    end
  end
end
