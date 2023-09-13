RSpec.describe StandardProcedure::Signal::Attribute do
  it "returns the original value" do
    ["String", 123, 45.6, Date.today, Time.now, false, nil].each do |value|
      attribute = StandardProcedure::Signal::Attribute.new value
      expect(attribute.get).to eq value
      expect(attribute.to_s).to eq value.to_s
    end
  end
end
