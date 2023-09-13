RSpec.describe Signal::Attribute::Array do
  it "is enumerable" do
    attribute = Signal::Attribute.array [1, 2]
    expect(attribute).to be_kind_of Enumerable
  end

  it "wraps its contents in attributes" do
    array = ["String", 123, 45.6, Date.today, Time.now, true]

    attribute = Signal::Attribute.array array

    array.each_with_index do |value, index|
      item = attribute.get[index]
      expect(item).to be_kind_of Signal::Attribute
      expect(item.get).to eq value
    end
  end

  it "wraps non-arrays in an array" do
    attribute = Signal::Attribute.array 123
    expect(attribute.count).to eq 1
    expect(attribute.first).to be_kind_of Signal::Attribute
    expect(attribute.first.get).to eq 123
  end

  it "does not wrap existing attributes" do
    array = [Signal::Attribute.new("String"), Signal::Attribute.new(123)]

    attribute = Signal::Attribute.array array

    array.each_with_index do |value, index|
      item = attribute.get[index]
      expect(item).to be_kind_of Signal::Attribute
      expect(item.get).to eq value.get
    end
  end

  it "pushes items onto the end of the array" do
    array = ["String", 123, 45.6, Date.today, Time.now, true]

    attribute = Signal::Attribute.array array

    count = array.count
    attribute.observe do
      count = attribute.get.count
    end

    attribute.push "new_item"

    expect(count).to eq(array.count + 1)
    expect(attribute.last).to eq "new_item"

    attribute << "another"

    expect(count).to eq(array.count + 2)
    expect(attribute.last).to eq "another"
  end

  it "pops items from the end of the array" do
    array = ["String", 123, 45.6]

    attribute = Signal::Attribute.array array

    count = array.count
    attribute.observe do
      count = attribute.get.count
    end

    popped_item = attribute.pop

    expect(popped_item.get).to eq 45.6
    expect(count).to eq(array.count - 1)
    expect(attribute.last.get).to eq 123
  end

  it "adds items to the start of the array" do
    array = ["String", 123, 45.6, Date.today, Time.now, true]

    attribute = Signal::Attribute.array array

    count = array.count
    attribute.observe do
      count = attribute.get.count
    end

    attribute.unshift "new_item"

    expect(count).to eq(array.count + 1)
    expect(attribute.first.get).to eq "new_item"
  end

  it "shifts items from the start of the array" do
    array = ["String", 123, 45.6]

    attribute = Signal::Attribute.array array

    count = array.count
    attribute.observe do
      count = attribute.get.count
    end

    shifted_item = attribute.shift

    expect(shifted_item.get).to eq "String"
    expect(count).to eq(array.count - 1)
    expect(attribute.first.get).to eq 123
  end

  it "preserves nils" do
    attribute = Signal::Attribute.array nil
    expect(attribute.get).to be_nil
  end
end
