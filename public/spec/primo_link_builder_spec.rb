require 'rspec'
require 'primo_request'

describe 'primo_link_builder' do
  let(:record) { { 'json' => { 'user_defined' => { 'string_2' => 'abcde1234' } } } }
  let(:subject) { PrimoLinkBuilder.new(record) }
  let(:response) { double }
  let(:json) { { 'docs' => { 0 => { '@id' => 'qrstuv0101' } } }
  let(:apikey) { 'jklmno9876' }
  let(:queryURL) { 
    'https://api-na.hosted.exlibrisgroup.com/primo/v1/search?' + 
    'inst=01ALLIANCE_UO&vid=ALLIANCE_UO&tab=default_tab&' +
    'scope=default_scope&q=any,contains,abcde1234&' +
    "apikey=#{apikey}"
  }
  before do
    allow(ASHTTP).to receive(:start_uri).and_return(response)
    allow(response).to receive(:body).and_return(json)
  end

  it 'builds the query link' do
    expect(build_link).to eq queryURL
  end

  it 'builds the view link' do
  end
end
