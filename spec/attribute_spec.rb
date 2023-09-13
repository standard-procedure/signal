# frozen_string_literal: true

RSpec.describe StandardProcedure::Signal::Attribute do
  it "observes a single StandardProcedure::Signal::Attribute" do
    attribute = StandardProcedure::Signal::Attribute.text "Hello"

    result = nil
    StandardProcedure::Signal.observe do
      result = attribute.get
    end
    expect(result).to eq "Hello"

    attribute.set "Goodbye"
    expect(result).to eq "Goodbye"
  end

  it "observes multiple StandardProcedure::Signal::Attributes" do
    first_name = StandardProcedure::Signal::Attribute.text "Kim"
    last_name = StandardProcedure::Signal::Attribute.text "West"

    result = nil
    StandardProcedure::Signal.observe do
      result = "#{first_name.get} #{last_name.get}"
    end
    expect(result).to eq "Kim West"

    last_name.set "Kardashian"
    expect(result).to eq "Kim Kardashian"

    first_name.set "Kourtney"
    expect(result).to eq "Kourtney Kardashian"
  end

  it "computes a value from multiple observed StandardProcedure::Signal::Attributes" do
    nickname = StandardProcedure::Signal::Attribute.text "Cocaine"
    first_name = StandardProcedure::Signal::Attribute.text "Kate"
    last_name = StandardProcedure::Signal::Attribute.text "Moss"
    is_tabloid = StandardProcedure::Signal::Attribute.boolean false

    name = StandardProcedure::Signal.compute do
      is_tabloid.get ? "#{nickname.get} #{first_name.get}" : "#{first_name.get} #{last_name.get}"
    end

    result = nil
    StandardProcedure::Signal.observe do
      result = name.get
    end
    expect(result).to eq "Kate Moss"

    is_tabloid.set true
    expect(result).to eq "Cocaine Kate"
  end

  it "batches updates" do
    attribute = StandardProcedure::Signal::Attribute.integer 0
    result = nil
    StandardProcedure::Signal.observe { result = attribute.get }
    expect(result).to eq 0
    StandardProcedure::Signal.update do
      attribute.set 1
      expect(result).to eq 0
      attribute.set 2
      expect(result).to eq 0
      attribute.set 3
      expect(result).to eq 0
    end
    expect(result).to eq 3
  end
end
