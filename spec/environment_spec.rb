require File.dirname(__FILE__) + '/spec_helper.rb'

describe EEML::Environment do

  describe "without any data" do

    it "can be created" do
      lambda {
        env = EEML::Environment.new
      }.should_not raise_error
    end

    it "raises an error when converted to EEML" do
      env = EEML::Environment.new
      lambda {
        env.to_eeml
      }.should raise_error(EEML::NoData, "EEML requires at least one data item")
    end

  end

  describe "after creation" do
    
    before(:each) do
      @env = EEML::Environment.new
    end

    it "can have a data item added to it" do
      lambda {
        @env << EEML::Data.new(36.2)
      }.should_not raise_error
      @env.size.should be(1)
    end

    it "can only have EEML::Data items added to it" do
      lambda {
        @env << 36.2
      }.should raise_error(TypeError, "Only EEML::Data objects can be added to EEML::Environment objects")
      @env.size.should be(0)
    end

    it "can have a title" do
      title = "A Room Somewhere"
      @env.title = title
      @env.title.should == title
    end

    it "can have a feed URL" do
      feed = "http://www.pachube.com/feeds/1.xml"
      @env.feed = feed
      @env.feed.should == feed
    end

    it "can have a status of 'frozen' or 'live'" do
      status = :frozen
      @env.status = status
      @env.status.should == status
      status = :live
      @env.status = status
      @env.status.should == status
    end

    it "rejects invalid status settings" do
      status = 'gibber'
      lambda {
        @env.status = status
      }.should raise_error(ArgumentError, "Status must be :frozen or :live")
    end

    it "can have a description" do
      description = "This is a room somewhere"
      @env.description = description
      @env.description.should == description
    end

    it "can have an icon URL" do
      icon = "http://www.roomsomewhere/icon.png"
      @env.icon = icon
      @env.icon.should == icon
    end

    it "can have a website URL" do
      website = "http://www.roomsomewhere/"
      @env.website = website
      @env.website.should == website
    end

    it "can have an associated email address" do
      email = "myemail@roomsomewhere"
      @env.email = email
      @env.email.should == email
    end

    it "can have a location" do
      location = EEML::Location.new(:physical, :exposure=>:indoor, :disposition=>:fixed,
                                    :name=>"My Room", :lat=>32.4, :lon=>22.7, :ele=>0.2)
      @env.location = location
      @env.location.should == location
    end

    it "cannot have an invalid object as a location" do
      lambda {
        @env.location = "cheese"
      }.should raise_error(TypeError, "loc must be an EEML::Location")
    end

    it "can have an updated_at time" do
      time = Time.now
      @env.updated_at = time
      @env.updated_at.should == time
    end

    it "allows client code to conveniently set updated_at to now" do
      t1 = Time.now
      @env.set_updated!
      t2 = Time.now
      @env.updated_at > t1
      @env.updated_at < t2
    end

    it "cannot have anything other than a Time object" do
      time = "cheese"
      lambda {
        @env.updated_at = time
      }.should raise_error(TypeError, "updated_at must be a Time object")
    end

    it "can have a creator string" do
      creator = "http://www.haque.co.uk"
      @env.creator = creator
      @env.creator.should == creator
    end

    it "can have an id" do
      id = 1
      @env.id = id
      @env.id.should == id
    end

  end

  describe "with a single data item" do
    
    before(:each) do
      @env = EEML::Environment.new
      @data = EEML::Data.new(36.2)
      @env << @data
    end

    it "generates the 'minimal' EEML example document" do
      @env.to_eeml.should == '<?xml version="1.0" encoding="UTF-8"?><eeml xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.eeml.org/xsd/005" xsi:schemaLocation="http://www.eeml.org/xsd/005 http://www.eeml.org/xsd/005/005.xsd"><environment><data id="0"><value>36.2</value></data></environment></eeml>'
    end

    it "should allow access to the data item" do
      @env[0].should be(@data)
    end

  end
  
  describe "with a single data item with ID=42" do

    before(:each) do
      @env = EEML::Environment.new
      @data = EEML::Data.new(36.2, :id => 42)
      @env << @data
    end

    it "generates something like the 'minimal' EEML example document" do
      @env.to_eeml.should == '<?xml version="1.0" encoding="UTF-8"?><eeml xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.eeml.org/xsd/005" xsi:schemaLocation="http://www.eeml.org/xsd/005 http://www.eeml.org/xsd/005/005.xsd"><environment><data id="42"><value>36.2</value></data></environment></eeml>'
    end

  end

  describe "being created from XML" do
    
    it "parses the 'minimal' EEML example document" do
      eeml = '<?xml version="1.0" encoding="UTF-8"?><eeml xmlns="http://www.eeml.org/xsd/005" xsi:schemaLocation="http://www.eeml.org/xsd/005 http://www.eeml.org/xsd/005/005.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><environment><data id="0"><value>36.2</value></data></environment></eeml>'
      env = EEML::Environment.from_eeml(eeml)
      env.size.should be(1)
      env[0].value.should be_close(36.2, 1e-9)
    end

  end

  describe "with everything set" do

    before(:each) do
      @env = EEML::Environment.new
      @env.title = "A Room Somewhere"
      @env.feed = "http://www.pachube.com/feeds/1.xml"
      @env.status = :frozen
      @env.description = "This is a room somewhere"
      @env.icon = "http://www.roomsomewhere/icon.png"
      @env.website = "http://www.roomsomewhere/"
      @env.email = "myemail@roomsomewhere"
      @env.updated_at = Time.utc(2007, 05, 04, 18, 13, 51)
      @env.creator = "http://www.haque.co.uk"
      @env.id = 1
      @env.location = EEML::Location.new(:physical, :exposure => :indoor, :disposition => :fixed, :name => "My Room", :lat => 32.4, :lon => 22.7, :ele => 0.2)
      @data0 = EEML::Data.new(36.2)
      @data0.tags << "temperature"
      @data0.max_value = 48.0
      @data0.min_value = 23.0
      @data0.unit = EEML::Unit.new("Celsius", :symbol => 'C', :type => :derivedSI)
      @env << @data0
      @data1 = EEML::Data.new(84.0)
      @data1.tags << "blush"
      @data1.tags << "redness"
      @data1.tags << "embarrassment"      
      @data1.max_value = 100.0
      @data1.min_value = 0.0
      @data1.unit = EEML::Unit.new("blushesPerHour", :type => :contextDependentUnits)
      @env << @data1
      @data2 = EEML::Data.new(12.3)
      @data2.tags << "length"
      @data2.tags << "distance"
      @data2.tags << "extension"
      @data2.min_value = 0.0
      @data2.unit = EEML::Unit.new("meter", :symbol => "m", :type => :basicSI)
      @env << @data2
    end

    it "generates the 'complete' EEML example document" do
      @env.to_eeml(5).should == '<?xml version="1.0" encoding="UTF-8"?><eeml version="5" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.eeml.org/xsd/005" xsi:schemaLocation="http://www.eeml.org/xsd/005 http://www.eeml.org/xsd/005/005.xsd"><environment updated="2007-05-04T18:13:51Z" creator="http://www.haque.co.uk" id="1"><title>A Room Somewhere</title><feed>http://www.pachube.com/feeds/1.xml</feed><status>frozen</status><description>This is a room somewhere</description><icon>http://www.roomsomewhere/icon.png</icon><website>http://www.roomsomewhere/</website><email>myemail@roomsomewhere</email><location domain="physical" exposure="indoor" disposition="fixed"><name>My Room</name><lat>32.4</lat><lon>22.7</lon><ele>0.2</ele></location><data id="0"><tag>temperature</tag><value maxValue="48.0" minValue="23.0">36.2</value><unit type="derivedSI" symbol="C">Celsius</unit></data><data id="1"><tag>blush</tag><tag>redness</tag><tag>embarrassment</tag><value maxValue="100.0" minValue="0.0">84.0</value><unit type="contextDependentUnits">blushesPerHour</unit></data><data id="2"><tag>length</tag><tag>distance</tag><tag>extension</tag><value minValue="0.0">12.3</value><unit type="basicSI" symbol="m">meter</unit></data></environment></eeml>'
    end
    
    it "populates the 'complete' EEML::Environment object from EEML XML" do
      @eeml = EEML::Environment.from_eeml(@env.to_eeml())
      @eeml.title.should == "A Room Somewhere"
      @eeml.creator.should == "http://www.haque.co.uk"
      @eeml.id.should == "1"
      @eeml.updated_at.should == Time.parse("2007-05-04T18:13:51Z")
      @eeml.description.should == "This is a room somewhere"
    end

    it "populates the EEML::Location object from EEML XML" do
      @eeml = EEML::Environment.from_eeml(@env.to_eeml())
      @eeml.location.class.name.should == "EEML::Location"
      @eeml.location.name.should == "My Room"
      @eeml.location.disposition == "fixed"
    end
    
    it "populates the EEML::Data object from EEML XML" do
      @eeml = EEML::Environment.from_eeml(@env.to_eeml())
      @eeml[0].tags[0].should == "temperature"
      @eeml[0].value.should == 36.2
    end
  end

end
