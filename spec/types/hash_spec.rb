RSpec.describe StandardProcedure::Signal::Attribute::Hash do
  it "is enumerable" do
    attribute = StandardProcedure::Signal::Attribute.hash key: "value"
    expect(attribute).to be_kind_of Enumerable
  end

  it "does not accept non-hashes" do
    expect { StandardProcedure::Signal::Attribute.hash 123 }.to raise_exception(ArgumentError)
  end

  it "knows its keys" do
    data = {key1: "value1", key2: 999}
    attribute = StandardProcedure::Signal::Attribute.hash data

    expect(attribute.keys).to eq data.keys
  end

  it "knows its values" do
    data = {key1: "value1", key2: 999}
    attribute = StandardProcedure::Signal::Attribute.hash data

    expect(attribute.values).to eq data.values
  end

  it "knows if it contains any data" do
    data = {key1: "value1", key2: 999}

    attribute = StandardProcedure::Signal::Attribute.hash data
    expect(attribute.any?).to eq true

    data = {}
    attribute = StandardProcedure::Signal::Attribute.hash data
    expect(attribute.any?).to eq false
  end

  it "knows if it is empty" do
    data = {key1: "value1", key2: 999}

    attribute = StandardProcedure::Signal::Attribute.hash data
    expect(attribute.empty?).to eq false

    data = {}
    attribute = StandardProcedure::Signal::Attribute.hash data
    expect(attribute.empty?).to eq true
  end

  it "knows if it includes a particular key" do
    data = {key1: "value1", key2: 999}

    attribute = StandardProcedure::Signal::Attribute.hash data
    expect(attribute.include?(:key1)).to eq true
    expect(attribute.include?(:not_a_key)).to eq false
  end

  it "knows if it has a particular key" do
    data = {key1: "value1", key2: 999}

    attribute = StandardProcedure::Signal::Attribute.hash data
    expect(attribute.has_key?(:key1)).to eq true
    expect(attribute.has_key?(:not_a_key)).to eq false
  end

  it "knows if it has a particular value" do
    data = {key1: "value1", key2: 999}

    attribute = StandardProcedure::Signal::Attribute.hash data
    expect(attribute.has_value?("value1")).to eq true
    expect(attribute.has_value?(999)).to eq true
    expect(attribute.has_value?("value3")).to eq false
  end

  it "knows its size" do
    data = {key1: "value1", key2: 999}

    attribute = StandardProcedure::Signal::Attribute.hash data
    expect(attribute.size).to eq 2
    expect(attribute.length).to eq 2
  end

  it "retrieves a key" do
    data = {key1: "value1", key2: 999}
    attribute = StandardProcedure::Signal::Attribute.hash data

    expect(attribute[:key1]).to eq "value1"
    expect(attribute.fetch(:key2)).to eq 999
  end

  it "sets a key" do
    data = {key1: "value1", key2: 999}
    attribute = StandardProcedure::Signal::Attribute.hash data

    size = data.size
    attribute.observe do
      size = attribute.size
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
    attribute = StandardProcedure::Signal::Attribute.hash data

    size = data.size
    attribute.observe do
      size = attribute.size
    end

    attribute.delete :key1

    expect(size).to eq(data.size - 1)
    expect(attribute[:key1]).to be_nil
  end

  it "clears all keys and values" do
    data = {key1: "value1", key2: 999}
    attribute = StandardProcedure::Signal::Attribute.hash data

    size = data.size
    attribute.observe do
      size = attribute.size
    end

    attribute.clear

    expect(size).to eq 0
    expect(attribute[:key1]).to be_nil
    expect(attribute[:key2]).to be_nil
  end

  it "preserves nils" do
    attribute = StandardProcedure::Signal::Attribute.array nil
    expect(attribute.get).to be_nil
  end
end
