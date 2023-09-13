RSpec.describe Signal::Attribute::Hash do
  it "is enumerable" do
    attribute = Signal::Attribute.hash key: "value"
    expect(attribute).to be_kind_of Enumerable
  end

  it "wraps its contents in attributes" do
    data = {key1: "value1", key2: 999}
    attribute = Signal::Attribute.hash data

    data.each do |key, value|
      item = attribute.get[key]
      expect(item).to be_kind_of Signal::Attribute
      expect(item.get).to eq value
    end
  end

  it "does not accept non-hashes" do
    expect { Signal::Attribute.hash 123 }.to raise_exception(ArgumentError)
  end

  it "does not wrap existing attributes" do
    data = {key1: Signal::Attribute.new("value1"), key2: Signal::Attribute.new(999)}
    attribute = Signal::Attribute.hash data

    data.each do |key, value|
      item = attribute.get[key]
      expect(item).to eq value
    end
  end

  it "knows its keys" do
    data = {key1: "value1", key2: 999}
    attribute = Signal::Attribute.hash data

    expect(attribute.keys).to eq data.keys
  end

  it "knows its values" do
    data = {key1: "value1", key2: 999}
    attribute = Signal::Attribute.hash data

    expect(attribute.values.map(&:get)).to eq data.values
  end

  it "knows if it contains any data" do
    data = {key1: "value1", key2: 999}

    attribute = Signal::Attribute.hash data
    expect(attribute.any?).to eq true

    data = {}
    attribute = Signal::Attribute.hash data
    expect(attribute.any?).to eq false
  end

  it "knows if it is empty" do
    data = {key1: "value1", key2: 999}

    attribute = Signal::Attribute.hash data
    expect(attribute.empty?).to eq false

    data = {}
    attribute = Signal::Attribute.hash data
    expect(attribute.empty?).to eq true
  end

  it "knows if it includes a particular key" do
    data = {key1: "value1", key2: 999}

    attribute = Signal::Attribute.hash data
    expect(attribute.include?(:key1)).to eq true
    expect(attribute.include?(:not_a_key)).to eq false
  end

  it "knows if it has a particular key" do
    data = {key1: "value1", key2: 999}

    attribute = Signal::Attribute.hash data
    expect(attribute.has_key?(:key1)).to eq true
    expect(attribute.has_key?(:not_a_key)).to eq false
  end

  it "knows if it has a particular attribute" do
    value1 = Signal::Attribute.new("value1")
    value2 = Signal::Attribute.new(999)
    value3 = Signal::Attribute.new(123)

    data = {key1: value1, key2: value2}

    attribute = Signal::Attribute.hash data
    expect(attribute.has_value?(value1, attribute: true)).to eq true
    expect(attribute.has_value?("value1", attribute: true)).to eq false
    expect(attribute.has_value?(value2, attribute: true)).to eq true
    expect(attribute.has_value?(999, attribute: true)).to eq false
    expect(attribute.has_value?(value3, attribute: true)).to eq false
    expect(attribute.has_value?(123, attribute: true)).to eq false
  end

  it "knows if it has a particular value" do
    value1 = Signal::Attribute.new("value1")
    value2 = Signal::Attribute.new(999)
    value3 = Signal::Attribute.new(123)

    data = {key1: value1, key2: value2}

    attribute = Signal::Attribute.hash data
    expect(attribute.has_value?(value1, attribute: false)).to eq false
    expect(attribute.has_value?("value1", attribute: false)).to eq true
    expect(attribute.has_value?(value2, attribute: false)).to eq false
    expect(attribute.has_value?(999, attribute: false)).to eq true
    expect(attribute.has_value?(value3, attribute: false)).to eq false
    expect(attribute.has_value?(123, attribute: false)).to eq false
  end

  it "knows its size" do
    data = {key1: "value1", key2: 999}

    attribute = Signal::Attribute.hash data
    expect(attribute.size).to eq 2
    expect(attribute.length).to eq 2
  end

  it "retrieves a key" do
    data = {key1: "value1", key2: 999}
    attribute = Signal::Attribute.hash data

    expect(attribute[:key1].get).to eq "value1"
    expect(attribute.fetch(:key2).get).to eq 999
  end

  it "sets a key" do
    data = {key1: "value1", key2: 999}
    attribute = Signal::Attribute.hash data

    size = data.size
    attribute.observe do
      size = attribute.get.size
    end

    attribute[:key3] = "something"

    expect(size).to eq(data.size + 1)
    expect(attribute[:key3]).to eq "something"

    attribute.store :key4, "another"

    expect(size).to eq(data.size + 2)
    expect(attribute[:key4]).to eq "another"
  end

  it "deletes a key" do
    data = {key1: "value1", key2: 999}
    attribute = Signal::Attribute.hash data

    size = data.size
    attribute.observe do
      size = attribute.get.size
    end

    attribute.delete :key1

    expect(size).to eq(data.size - 1)
    expect(attribute[:key1]).to be_nil
  end

  it "clears all keys and values" do
    data = {key1: "value1", key2: 999}
    attribute = Signal::Attribute.hash data

    size = data.size
    attribute.observe do
      size = attribute.get.size
    end

    attribute.clear

    expect(size).to eq 0
    expect(attribute[:key1]).to be_nil
    expect(attribute[:key2]).to be_nil
  end

  it "preserves nils" do
    attribute = Signal::Attribute.array nil
    expect(attribute.get).to be_nil
  end
end
