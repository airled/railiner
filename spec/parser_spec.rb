require 'rails_helper'
require_relative '../lib/parser'

describe 'Default parser' do
  parser = Parser.new
  it 'should not be daemon' do
      expect(parser.daemon?).to eq(false)
  end
  it 'should not have queues' do
      expect(parser.queue?).to eq(false)
  end
end

describe 'Parser as daemon' do
  parser = Parser.new(true, false)
  it 'should not be daemon' do
      expect(parser.daemon?).to eq(true)
  end
  it 'should not have queues' do
      expect(parser.queue?).to eq(false)
  end
end

describe 'Parser with queues' do
  parser = Parser.new(false, true)
  it 'should not be daemon' do
      expect(parser.daemon?).to eq(false)
  end
  it 'should not have queues' do
      expect(parser.queue?).to eq(true)
  end
end

describe 'Parser as daemon with queues' do
  parser = Parser.new(true, true)
  it 'should not be daemon' do
      expect(parser.daemon?).to eq(true)
  end
  it 'should not have queues' do
      expect(parser.queue?).to eq(true)
  end
end

# describe '' do
#   parser = Parser.new
# end

