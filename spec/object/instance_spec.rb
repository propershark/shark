module Shark
  describe Object, 'instance' do
    it 'is configurable' do
      expect(subject).to respond_to(:configuration)
      expect(subject.configuration).to be_a(Configuration)
    end

    context '#configuration' do
      it 'is distinct from the class configuration' do
        expect(subject.configuration).to_not equal(subject.class.configuration)
      end
    end


    context '#initialize' do
      it 'gives a default value to #associated_objects' do
        expect(subject.associated_objects).to_not be_nil
      end

      it 'accepts attribute assignments as a hash' do
        object = Object.new(attr1: :value1, attr2: :value2)
        expect(object.instance_variable_get("@attr1")).to eq(:value1)
        expect(object.instance_variable_get("@attr2")).to eq(:value2)
      end
    end


    context '#associated_objects' do
      it 'tracks objects in a hash-like structure of iterables' do
        expect(subject.associated_objects).to respond_to(:[])
        expect(subject.associated_objects[Object]).to respond_to(:each)
      end

      it 'returns a blank list when a type does not exist' do
        expect(subject.associated_objects[Object]).to respond_to(:each)
      end

      it 'groups objects of the same type' do
        subject.associate(Object, 'objects.test1')
        subject.associate(Object, 'objects.test2')
        expect(subject.associated_objects[Object]).to include('objects.test1', 'objects.test2')
      end

      it 'maintains separate lists for different types' do
        type1 = Class.new(Object)
        type2 = Class.new(Object)
        subject.associate(type1, 'type1.test')
        subject.associate(type2, 'type2.test')
        expect(subject.associated_objects[type1]).to contain_exactly('type1.test')
        expect(subject.associated_objects[type2]).to contain_exactly('type2.test')
        expect(subject.associated_objects[type1]).to_not include('type2.test')
        expect(subject.associated_objects[type2]).to_not include('type1.test')
      end

      it 'ensures uniqueness of entries' do
        subject.associate(Object, 'objects.test')
        subject.associate(Object, 'objects.test')
        expect(subject.associated_objects[Object].size).to be 1
      end
    end


    context '#associate' do
      it 'adds objects to #associated_objects' do
        subject.associate(Object, 'objects.test')
        expect(subject.associated_objects[Object]).to include('objects.test')
      end

      it 'only associates the given object' do
        subject.associate(Object, 'objects.test')
        expect(subject.associated_objects[Object]).to contain_exactly('objects.test')
      end

      it 'returns a truthy value if the association was actually created' do
        expect(subject.associate(Object, 'objects.test')).to be_truthy
      end

      it 'returns false if the association did already exist' do
        subject.associate(Object, 'objects.test')
        expect(subject.associate(Object, 'objects.test')).to be_falsy
      end
    end


    context '#dissociate' do
      before :each do
        subject.associate(Object, 'objects.test1')
        subject.associate(Object, 'objects.test2')
      end

      it 'removes objects from #associated_objects' do
        subject.dissociate(Object, 'objects.test1')
        expect(subject.associated_objects[Object]).to_not include('objects.test1')
      end

      it 'only dissociates the given object' do
        subject.dissociate(Object, 'objects.test1')
        expect(subject.associated_objects[Object]).to include('objects.test2')
      end

      it 'returns a truthy value if the association was actually removed' do
        expect(subject.dissociate(Object, 'objects.test1')).to be_truthy
      end

      it 'returns false if the association did not exist' do
        subject.dissociate(Object, 'objects.test1')
        expect(subject.dissociate(Object, 'objects.test1')).to be_falsy
      end
    end


    context '#dissociate_all' do
      it 'removes all associations of the given type' do
        subject.associate(Object, 'objects.test1')
        subject.associate(Object, 'objects.test2')
        subject.dissociate_all(Object)

        expect(subject.associated_objects[Object]).to be_empty
      end

      it 'only removes objects of the given type' do
        type1 = Class.new(Object)
        type2 = Class.new(Object)
        subject.associate(type1, 'type1.test')
        subject.associate(type2, 'type2.test')
        subject.dissociate_all(type1)

        expect(subject.associated_objects[type1]).to be_empty
        expect(subject.associated_objects[type2]).to include('type2.test')
      end
    end


    context '#has_association_to' do
      it 'returns true if an association to the given object exists' do
        subject.associate(Object, 'objects.test1')
        expect(subject.has_association_to(Object, 'objects.test1')).to be_truthy
      end

      it 'returns false if no association to the given object exists' do
        expect(subject.has_association_to(Object, 'objects.test1')).to be_falsy
      end
    end

    context '#assign' do
      it 'assigns instance variables for every argument given' do
        subject.assign(attr1: :value1, attr2: :value2)
        expect(subject.instance_variable_get("@attr1")).to eq(:value1)
        expect(subject.instance_variable_get("@attr2")).to eq(:value2)
      end
    end


    context '#identifier' do
      before :all do
        IdentifiableObject = Class.new(Object)
        IdentifiableObject.attribute :name
        IdentifiableObject.primary_attribute :name
      end

      subject { IdentifiableObject.new }

      it 'returns a valid identifier for the object' do
        subject.name    = 'test1'
        expected_ident  = IdentifiableObject.identifier_for('test1')
        expect(subject.identifier).to eq(expected_ident)
      end
    end
  end
end
