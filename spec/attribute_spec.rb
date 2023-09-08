# frozen_string_literal: true

RSpec.describe Attribute do
  it "observes a single attribute" do
    attribute = Attribute.text "Hello"

    result = nil
    attribute.observe do
      result = attribute.get
    end
    expect(result).to eq "Hello"

    attribute.set "Goodbye"
    expect(result).to eq "Goodbye"
  end

  it "observes multiple attributes" do
    first_name = Attribute.text "Kim"
    last_name = Attribute.text "West"

    result = nil
    Attribute.observe do
      result = "#{first_name.get} #{last_name.get}"
    end
    expect(result).to eq "Kim West"

    last_name.set "Kardashian"
    expect(result).to eq "Kim Kardashian"

    first_name.set "Kourtney"
    expect(result).to eq "Kourtney Kardashian"
  end

  it "computes a value from multiple observed attributes" do
    nickname = Attribute.text "Cocaine"
    first_name = Attribute.text "Kate"
    last_name = Attribute.text "Moss"
    is_tabloid = Attribute.boolean false

    name = Attribute.compute do
      is_tabloid.get ? "#{nickname.get} #{first_name.get}" : "#{first_name.get} #{last_name.get}"
    end

    result = nil
    Attribute.observe do
      result = name.get
    end
    expect(result).to eq "Kate Moss"

    is_tabloid.set true
    expect(result).to eq "Cocaine Kate"
  end

  it "batches updates" do
    attribute = Attribute.integer 0
    result = nil
    attribute.observe { result = attribute.get }
    expect(result).to eq 0
    Attribute.update do
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
