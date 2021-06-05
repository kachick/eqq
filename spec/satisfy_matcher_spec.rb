# coding: utf-8
# frozen_string_literal: true

RSpec.describe RSpec::Matchers::BuiltIn::Satisfy do
  let(:product) { Eqq.AND(Integer, 24..42) }

  it 'perfectly works' do
    expect(23).not_to satisfy(&product)
    expect(24).to satisfy(&product)
    expect(24.0).not_to satisfy(&product)
    expect(42).to satisfy(&product)
    expect(42.0).not_to satisfy(&product)
    expect(43).not_to satisfy(&product)
  end
end
