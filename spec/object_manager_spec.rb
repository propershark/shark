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
    let(:agency) { Shark::Agency.new }
    subject { ObjectManager.new('test_manager', agency) }

    it 'is configurable' do
      expect(subject).to respond_to(:configuration)
      expect(subject.configuration).to be_a(Configuration)
    end


    context '#initialize' do
      before :all do
        require './source.rb'
        Source.register_source(:test_source1, Object, Source::NormalSource)
        config = ObjectManager.configure do |c|
          c.object_type       = Object
          c.update_frequency  = '2s'
          c.source_from :test_source1
        end
      end

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
        config = ObjectManagerConfiguration.new.tap do |c|
          c.object_type       = Object
          c.update_frequency  = '2s'
          c.source_from :test_source1
        end
        object = ObjectManager.new('test_manager', agency)
        expect(object.klass).to eq(config.object_type)
        expect(object.update_frequency).to eq(config.update_frequency)
        expect(object.sources.size).to eq(1)
      end

      it 'creates Source instances for each source in the configuration' do
        object = ObjectManager.new('test_manager', agency)
      end
    end

    context '#activate' do
    end

    context '#deactivate' do
    end

    context '#deactivate_all' do
    end

    context '#remove' do
    end

    context '#find' do
    end

    context '#find_or_new' do
    end

    context '#each' do
    end

    context 'update' do
    end
  end
end
