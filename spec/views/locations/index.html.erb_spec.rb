require 'spec_helper'

describe "locations/index" do
  before(:each) do
    assign(:locations, [
      stub_model(Location,
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
      ),
      stub_model(Location,
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
      )
    ])
  end

  it "renders a list of locations" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Description".to_s, :count => 2
    assert_select "tr>td", :text => "Link".to_s, :count => 2
    assert_select "tr>td", :text => "Modern Location".to_s, :count => 2
    assert_select "tr>td", :text => "Historical Name".to_s, :count => 2
    assert_select "tr>td", :text => "Admin01".to_s, :count => 2
    assert_select "tr>td", :text => "Admin02".to_s, :count => 2
    assert_select "tr>td", :text => "Town".to_s, :count => 2
    assert_select "tr>td", :text => "Location Type".to_s, :count => 2
    assert_select "tr>td", :text => "Variable Names".to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
