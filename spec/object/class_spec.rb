module Shark
  describe Object, 'class' do
    subject { Object }

    it 'is configurable' do
      expect(subject.ancestors).to include(Configurable)
      expect(subject).to respond_to(:configuration)
      expect(subject.configuration).to be_a(Configuration)
    end

    it 'is schemable' do
      expect(subject.ancestors).to include(Schemable)
    end

    it 'is serializable' do
      expect(subject.ancestors).to include(Serializable)
    end


    it 'has no attributes' do
      expect(subject.attributes).to be_empty
    end

    it 'can generate object identifiers' do
      ident = subject.identifier_for('test')
      expect(ident).to eq "objects.test"
    end


    context '::configuration' do
      subject { Object.configuration }
      it 'is valid according to the schema' do
        expect(subject.validate!).to be_truthy
      end

      it 'covers all options for Serializable' do
        expect(subject).to respond_to(:serialized_attributes)
        expect(subject).to respond_to(:embedded_objects)
        expect(subject).to respond_to(:embed_associated_objects)
        expect(subject).to respond_to(:nested_serialized_attributes)
        expect(subject).to respond_to(:nested_embedded_objects)
        expect(subject).to respond_to(:nested_embed_associated_objects)
      end
    end


    it 'defines configuration inheritance for subclasses' do
      subclass = Class.new(Object)
      expect(subclass).to include(Configurable)
      # With no changes in the subclass, the configuration of Object and the
      # subclass should be equivalent.
      # expect(subclass.configuration).to eq Shark::Object.configuration
    end
  end
end
