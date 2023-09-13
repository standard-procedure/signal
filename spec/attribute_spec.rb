# frozen_string_literal: true

RSpec.describe StandardProcedure::Signal::Attribute do
  include StandardProcedure::Signal
  it "observes a single StandardProcedure::Signal::Attribute" do
    a = attribute.text "Hello"

    result = nil
    observe do
      result = a.get
    end
    expect(result).to eq "Hello"

    a.set "Goodbye"
    expect(result).to eq "Goodbye"
  end

  it "observes multiple StandardProcedure::Signal::Attributes" do
    first_name = attribute.text "Kim"
    last_name = attribute.text "West"

    result = nil
    observe do
      result = "#{first_name.get} #{last_name.get}"
    end
    expect(result).to eq "Kim West"

    last_name.set "Kardashian"
    expect(result).to eq "Kim Kardashian"

    first_name.set "Kourtney"
    expect(result).to eq "Kourtney Kardashian"
  end

  it "computes a value from multiple observed StandardProcedure::Signal::Attributes" do
    nickname = attribute.text "Cocaine"
    first_name = attribute.text "Kate"
    last_name = attribute.text "Moss"
    is_tabloid = attribute.boolean false

    name = compute do
      is_tabloid.get ? "#{nickname.get} #{first_name.get}" : "#{first_name.get} #{last_name.get}"
    end

    result = nil
    observe do
      result = name.get
    end
    expect(result).to eq "Kate Moss"

    is_tabloid.set true
    expect(result).to eq "Cocaine Kate"
  end

  it "batches updates" do
    a = attribute.integer 0
    result = nil
    observe { result = a.get }
    expect(result).to eq 0
    update do
      a.set 1
      expect(result).to eq 0
      a.set 2
      expect(result).to eq 0
      a.set 3
      expect(result).to eq 0
    end
    expect(result).to eq 3
  end
end
