require "spec_helper"

shared_examples_for "ActiveModel" do
  require 'test/unit/assertions'
  require 'active_model/lint'
  include Test::Unit::Assertions
  include ActiveModel::Lint::Tests

  def model
    ActiveConductor.new
  end
end

describe ActiveConductor do
  it_should_behave_like "ActiveModel"

  describe ".conduct" do
    let(:conductor) do
      Class.new(ActiveConductor) do
        def record
          @record ||= Record.new
        end

        def models
          [record]
        end

        conduct :record, :an_int
      end.new
    end

    it "conducts the attributes to the model" do
      conductor.an_int = 10
      conductor.record.an_int.should == 10
    end
  end

  context do
    let(:model) do
      Class.new(ActiveConductor) do
        def models
          [person]
        end

        conduct :person, :name

        def person
          @person ||= Person.new
        end
      end
    end

    describe "#initialize" do
      let(:conductor) { model.new(:name => "Scott") }

      it "sets the model attributes from the conductor initializer" do
        conductor.name.should == "Scott"
      end
    end

    describe "#attributes=" do
      let(:conductor) { model.new }

      context "with valid attributes" do
        before { conductor.attributes = { :name => "Scott Taylor" } }

        it "sets the model attributes from the attributes method" do
          conductor.name.should == "Scott Taylor"
          conductor.person.name.should == "Scott Taylor"
        end
      end

      context "with invalid attributes" do
        before do
          conductor.attributes = { :name => "Scott Taylor" }
          conductor.attributes = nil
        end

        it "ignores the value" do
          conductor.name.should eql "Scott Taylor"
        end
      end
    end
  end

  describe "#new_record?" do
    context "with one new model and one saved model" do
      let(:conductor) do
        Class.new(ActiveConductor) do
          def models
            saved_record = Record.new
            saved_record.save!

            [saved_record, Record.new]
          end
        end.new
      end

      it "is false" do
        conductor.new_record?.should be_false
      end
    end

    context "with one saved model" do
      let(:conductor) do
        Class.new(ActiveConductor) do
          def models
            saved_record = Record.new
            saved_record.save!
            [saved_record]
          end
        end.new
      end

      it "is false" do
        conductor.new_record?.should be_false
      end
    end

    context "with one new model" do
      let(:conductor) do
        Class.new(ActiveConductor) do
          def models
            [Record.new]
          end
        end.new
      end

      it "is true" do
        conductor.new_record?.should be_true
      end
    end
  end

  describe "#valid?" do
    context "with no models" do
      let(:conductor) { Class.new(ActiveConductor).new }

      it "is true" do
        conductor.should be_valid
      end
    end

    context "with one valid model" do
      let(:conductor) do
        Class.new(ActiveConductor) do
          def models
            [person]
          end

          def person
            @person ||= Person.new(:name => "Scott Taylor")
          end
        end.new
      end

      it "is true" do
        conductor.should be_valid
      end
    end

    context "with one invalid model" do
      let(:conductor) do
        Class.new(ActiveConductor) do
          def models
            [person]
          end

          def person
            @person ||= Person.new
          end
        end.new
      end

      it "is false" do
        conductor.should_not be_valid
      end
    end
  end

  describe "#errors" do
    let(:conductor) do
      Class.new(ActiveConductor) do
        def person
          @person ||= Person.new
        end

        def models
          [person]
        end
      end.new
    end

    it "reports the errors from the model" do
      conductor.valid?
      conductor.errors[:name].should == ["can't be blank"]
    end
  end

  context do
    let(:conductor_class) do
      Class.new(ActiveConductor) do
        def models
          [person]
        end

        def person
          @person ||= Person.new
        end

        conduct :person, :name
      end
    end

    describe "#save" do
      let(:conductor) { conductor_class.new }

      context "without validation errors" do
        it "saves the model" do
          conductor.name = "Scott"
          conductor.person.should_receive(:save)
          conductor.save
        end

        it "returns true" do
          conductor.name = "Scott"
          conductor.save.should be_true
        end
      end

      context "with validation errors" do
        it "does not save the model" do
          conductor.person.should_not_receive(:save)
          conductor.save
        end

        it "returns false" do
          conductor.name = nil
          conductor.save.should be_false
        end
      end

      context "with an error when saving a valid model" do
        it "returns false" do
          conductor.person.stub!(:valid?).and_return true
          conductor.person.stub!(:save).and_return false
          conductor.save.should be_false
        end
      end
    end

    describe ".create" do
      context "without validation errors" do
        it "saves the model" do
          expect { conductor_class.create(:name => "Scott") }.to change(Person, :count).by(1)
        end

        it "returns the created conductor" do
          conductor_class.create(:name => "Scott").should be_kind_of(ActiveConductor)
        end
      end

      context "with validation errors" do
        it "does not save the model" do
          expect { conductor_class.create(:name => "") }.not_to change(Person, :count).by(1)
        end

        it "returns the created conductor" do
          conductor_class.create(:name => "").should be_kind_of(ActiveConductor)
        end
      end

      context "with an optional block" do
        it "switches the context to the block before save" do
          expect do
            conductor_class.create(:name => "") do |c|
              c.name = "Scott"
            end
          end.to change(Person, :count).by(1)
        end
      end
    end
  end

  describe "#destroyed?" do
    it "should not be destroyed" do
      conductor = ActiveConductor.new
      conductor.should_not be_destroyed
    end
  end

  describe "persisted?" do
    it "should not be persisted" do
      conductor = ActiveConductor.new
      conductor.should_not be_persisted
    end
  end
end
