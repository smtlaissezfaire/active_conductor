require "active_model"
require "forwardable"

class ActiveConductor
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  extend Forwardable

  def self.conduct(obj, *attributes)
    attributes.each do |attr|
      def_delegator obj, attr
      def_delegator obj, "#{attr}="
    end
  end

  def initialize(params={})
    self.attributes = params
  end

  def valid?
    result = true

    models.each do |model|
      if !model.valid?
        result = false
      end

      model.errors.each do |field, value|
        errors.add(field, value)
      end
    end

    result
  end

  def new_record?
    models.all? { |m| m.new_record? }
  end

  def errors
    @errors ||= ActiveModel::Errors.new(self)
  end

  def models
    []
  end

  def save
    if valid?
      models.each do |model|
        unless model.save
          return false
        end
      end

      true
    end
  end

  def attributes=(params)
    params.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  # ActiveModel compatibility
  def destroyed?
    false
  end

  def persisted?
    false
  end

end
