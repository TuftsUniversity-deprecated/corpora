require 'spec_helper'

describe "locations/new" do
  before(:each) do
    assign(:location, stub_model(Location,
      :name => "MyString",
      :description => "MyString",
      :link => "MyString",
      :modern_location => "MyString",
      :historical_name => "MyString",
      :admin01 => "MyString",
      :admin02 => "MyString",
      :town => "MyString",
      :location_type => "MyString",
      :variable_names => "MyString",
      :latitutde => 1.5,
      :longitude => 1.5,
      :external_feature_id => 1
    ).as_new_record)
  end

  it "renders new location form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", locations_path, "post" do
      assert_select "input#location_name[name=?]", "location[name]"
      assert_select "input#location_description[name=?]", "location[description]"
      assert_select "input#location_link[name=?]", "location[link]"
      assert_select "input#location_modern_location[name=?]", "location[modern_location]"
      assert_select "input#location_historical_name[name=?]", "location[historical_name]"
      assert_select "input#location_admin01[name=?]", "location[admin01]"
      assert_select "input#location_admin02[name=?]", "location[admin02]"
      assert_select "input#location_town[name=?]", "location[town]"
      assert_select "input#location_location_type[name=?]", "location[location_type]"
      assert_select "input#location_variable_names[name=?]", "location[variable_names]"
      assert_select "input#location_latitutde[name=?]", "location[latitutde]"
      assert_select "input#location_longitude[name=?]", "location[longitude]"
      assert_select "input#location_external_feature_id[name=?]", "location[external_feature_id]"
    end
  end
end
