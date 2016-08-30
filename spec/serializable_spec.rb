module Shark
  describe Serializable do
    before :all do
      class DummyClass < Object
        attribute :name
        attribute :list
        attribute :hash

        primary_attribute :name

        configuration = Configuration.new
        configuration.schema do
          optional :serialized_attributes, default: ->{ attributes }
          optional :embedded_objects, default: []
          optional :embed_associated_objects, default: false

          optional :nested_serialized_attributes, default: ->{ attributes }
          optional :nested_embedded_objects, default: []
          optional :nested_embed_associated_objects,  default: false
        end
      end
    end

    let(:nested1)   { DummyClass.new(name: 'nested1') }
    let(:nested21)  { DummyClass.new(name: 'nested21') }
    let(:nested22)  { DummyClass.new(name: 'nested22') }
    let(:nested2)   { DummyClass.new(name: 'nested2', list: [nested21.identifier, nested22.identifier]) }

    subject do
      dummy = DummyClass.new(
        name: 'Main',
        list: [nested1.identifier, nested2.identifier],
        hash: {
          symbol: :value,
          number: 15,
          object: nested1.identifier
        }
      )

      dummy.associate(DummyClass, nested1.identifier)
      dummy.associate(DummyClass, nested2.identifier)
      dummy
    end

    it 'defines `to_h` and `to_json` implementations for Objects' do
      expect(subject).to respond_to(:to_h)
      expect(subject).to respond_to(:to_json)
    end

    context 'with a default configuration' do
      let(:serialized) { subject.to_h }

      it 'includes all attributes' do
        expect(serialized).to include(:name, :list, :hash)
      end

      it 'does not embed Object instances' do
        expect(serialized[:list]).to match([nested1.identifier, nested2.identifier])
      end

      it 'does not embed Object instances in `associated_objects`' do
        expect(serialized[:associated_objects][DummyClass]).to match([nested1.identifier, nested2.identifier])
      end

      context 'when nested' do
        it 'includes all attributes'
        it 'does not embed Object instances'
        it 'does not embed Object instances in `associated_objects`'
      end
    end
  end
end
