require 'spec_helper'

describe "locations/show" do
  before(:each) do
    @location = assign(:location, stub_model(Location,
      :name => "Name",
      :description => "Description",
      :link => "Link",
      :modern_location => "Modern Location",
      :historical_name => "Historical Name",
      :admin01 => "Admin01",
      :admin02 => "Admin02",
      :town => "Town",
      :location_type => "Location Type",
      :variable_names => "Variable Names",
      :latitutde => 1.5,
      :longitude => 1.5,
      :external_feature_id => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(/Description/)
    rendered.should match(/Link/)
    rendered.should match(/Modern Location/)
    rendered.should match(/Historical Name/)
    rendered.should match(/Admin01/)
    rendered.should match(/Admin02/)
    rendered.should match(/Town/)
    rendered.should match(/Location Type/)
    rendered.should match(/Variable Names/)
    rendered.should match(/1.5/)
    rendered.should match(/1.5/)
    rendered.should match(/1/)
  end
end
