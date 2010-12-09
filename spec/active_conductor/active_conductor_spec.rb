require "spec_helper"

shared_examples_for "ActiveModel" do
  require 'test/unit/assertions'
  require 'active_model/lint'
  include Test::Unit::Assertions
  include ActiveModel::Lint::Tests

  # to_s is to support ruby-1.9
  ActiveModel::Lint::Tests.public_instance_methods.map { |m| m.to_s }.grep(/^test/).each do |m|
    example m.gsub('_',' ') do
      send m
    end
  end

  def model
    @model
  end
end

describe ActiveConductor do
  describe "ActiveModel compliance" do
    before do
      @model = ActiveConductor.new
    end

    it_should_behave_like "ActiveModel"
  end

  it "should not be destroyed" do
    @model = ActiveConductor.new
    @model.should_not be_destroyed
  end

  it "should not be persisted" do
    @model = ActiveConductor.new
    @model.should_not be_persisted
  end

  describe "new_record?" do
    before do
      @one_new_model_one_saved_model_class = Class.new(ActiveConductor) do
        def models
          saved_record = Record.new
          saved_record.save!
          new_record = Record.new

          [saved_record, new_record]
        end
      end

      @one_saved_model = Class.new(ActiveConductor) do
        def models
          saved_record = Record.new
          saved_record.save!
          [saved_record]
        end
      end

      @one_new_model = Class.new(ActiveConductor) do
        def models
          [Record.new]
        end
      end
    end

    it "should be true if all of the models are new records" do
      @obj = @one_new_model.new
      @obj.new_record?.should be_true
    end

    it "should be false if there are only saved records" do
      @obj = @one_saved_model.new
      @obj.new_record?.should be_false
    end

    it "should be false if there is one saved records and one new record" do
      @obj = @one_new_model_one_saved_model_class.new
      @obj.new_record?.should be_false
    end
  end

  describe "conducting" do
    before do
      @conductor = Class.new(ActiveConductor) do
        def record
          @record ||= Record.new
        end

        def models
          [record]
        end

        conduct :record, :an_int
      end.new
    end

    it "should conduct attributes" do
      @conductor.an_int = 10
      @conductor.an_int.should == 10

      @conductor.record.an_int.should == 10
    end
  end

  describe "errors" do
    before do
      @conductor = Class.new(ActiveConductor) do
        def person
          @person ||= Person.new
        end

        def models
          [person]
        end
      end.new
    end

    it "should report errors from the model" do
      @conductor.valid?
      @conductor.errors[:name].should == ["can't be blank"]
    end
  end

  describe "valid" do
    it "should be true with no models" do
      obj = Class.new(ActiveConductor).new
      obj.should be_valid
    end

    it "should be true with one valid model" do
      @person_conductor = Class.new(ActiveConductor) do
        def models
          [person]
        end

        def person
          @person ||= Person.new(:name => "Scott Taylor")
        end
      end.new

      @person_conductor.should be_valid
    end

    it "should be false with one invalid model" do
      @person_conductor = Class.new(ActiveConductor) do
        def models
          [person]
        end

        def person
          @person ||= Person.new
        end
      end.new

      @person_conductor.should_not be_valid
    end
  end

  describe "save" do
    before do
      @person_conductor_class = Class.new(ActiveConductor) do
        def models
          [person]
        end

        def person
          @person ||= Person.new
        end

        conduct :person, :name
      end

      @person_conductor = @person_conductor_class.new
    end

    it "should save each model" do
      @person_conductor.name = "Scott"

      @person_conductor.person.should_receive(:save)
      @person_conductor.save
    end

    it "should not save if not valid" do
      @person_conductor.person.should_not_receive(:save)
      @person_conductor.save
    end

    it "should return true if all models saved successfully" do
      @person_conductor.name = "Scott"
      @person_conductor.save.should be_true
    end

    it "should return false if not valid" do
      @person_conductor.name = nil
      @person_conductor.save.should be_false
    end

    it "should return false if one of the models doesn't save (but is valid)" do
      @person_conductor.person.stub!(:valid?).and_return true
      @person_conductor.person.stub!(:save).and_return false
      @person_conductor.save.should be_false
    end
  end

  describe "assigning attributes" do
    before do
      @person_conductor_class = Class.new(ActiveConductor) do
        def models
          [person]
        end

        conduct :person, :name

        def person
          @person ||= Person.new
        end
      end

      @person_conductor = @person_conductor_class.new
    end

    it "should be able to set attributes" do
      @person_conductor.attributes = {
        :name => "Scott Taylor"
      }

      @person_conductor.name.should == "Scott Taylor"
      @person_conductor.person.name.should == "Scott Taylor"
    end
  end
end