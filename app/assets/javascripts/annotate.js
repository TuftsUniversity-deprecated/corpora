

// after the page is loaded, init variables holding people, concepts and places
//  and annotate the transcript
jQuery(document).ready(initDataAndTabs);



// the functions initPeople, initConcepts and initPlaces are created
//   by code in AnnotationHelper, they return json data for people, places and concepts
function initDataAndTabs(annotate_transcript)
{
    initConfigHash();
    var people = initPeople();
    addType(people, "person");
    extraData.person.data = people;

    var concepts = initConcepts();
    addType(concepts, "concept");
    extraData.concept.data = concepts;

    var places = initPlaces();
    addType(places, "place");
    extraData.place.data = places;

    // add all the data to a single array
    elements = people.concat(concepts, places);
    initTabs();

    if (annotate_transcript)
    {
        annotateTranscript();
    }


    showMapCanvas(true);

    var mapTab = jQuery("#tab4");
    mapTab.on("click", function(){delayedInitMap();})

    history = window.History;
    History.Adapter.bind(window,'statechange', processUrlStateChange);
    var state = History.getState();
    $("#navTabsUl").on("shown", tabClicked);  // need to update history when tab is clicked

    processUrlStateChange();   // process URL in case it includes a deep link
    tabWithoutHistory = false;
};

// sometimes we have to select the tab without pushing a history change
var tabWithoutHistory = true;

// url is catalog/pid/type/arg
// where type is person, place or concept
// when there is no arg,
function processUrlStateChange()
{
    var currentState = History.getState();
    var url = currentState.url;
    var parts = url.split(/\/|\?/);
    var type = parts[parts.length - 1];
    var element = null;
    if ((type == "catalog") || (url.indexOf('?') == -1) || type == "transcript")
    {
        // here if we should be on the application's home tab
        jQuery("#tab1").click();
    }
    if ((type != "concept") && (type != "place") && (type != "person") && (type != 'time') && (type != 'map') && (type != 'timestamp'))
    {
        element = type;
        type = parts[parts.length - 2];
    }
    console.log("type = " + type);
    if ((type == "concept") || (type == 'person') || (type == 'place'))
    {
        if (element == null)
        {
            console.log("processing url state change to list " + type);
            showList(type);
        }
        else
        {
            console.log("processing url state change to element " + element);
            showElement(element);
        }
    }
    else if (type == 'timestamp')
    {
        // timestamp on UI has the format minutes:seconds.  it does not use hours
        // we use the same format for a deep linking url
        var timestamp = element;
        var parts = timestamp.split(':');
        if (parts.length == 0)
            return;
        var minutes = parseInt(parts[0]);
        if (isNaN(minutes))
            return;  // if minutes are bad, skip setting player
        var seconds = 0;
        if (parts.length > 1)
            seconds = parseInt(parts[1]);
        if (isNaN(seconds))
            seconds = 0;  // if seconds are bad, ignore seconds

        var time = (minutes * 60 + seconds) * 1000;
        console.log("jumping to " + time);
        jumpPlayerTo(time);

    }
    else if (type == "map")
    {
        var configHash = extraData['place'];
        jQuery(configHash.tabId).click();
        showMapCanvas(false);
    }
}

function tabClicked(event, eventData)
{
    // if we are initing the page, we don't want to push this history because it is already there
    if (tabWithoutHistory == true)
        return;
    var tab = event.target.id;
    if (tab == "tab5")
        pushHistory("concept");
    else if (tab == "tab3")
        pushHistory("person");
    else if (tab == "tab4")
        pushHistory("place");
    else if (tab == "tab2")
        pushHistory("transcript");

}

function requestShowList(type)
{
     pushHistory(type);
}

function requestShowElement(name)
{
    var element = getElement(name);
    if (element == null)
        return;
    var type = element.type;
    pushHistory(type, name);
}

function requestShowMapCanvas()
{
    pushHistory("map");
}

function pushHistory(type, name)
{
    if (name == null)
    {
        History.pushState(null, document.title, "?" + type);
    }
    else
        History.pushState(null, document.title, "?" + type + "/" + name);
}


// if the map is created on page load it displays incorrectly
//   because it doesn't receive a resize when the div is initialized after its first display
//   so the map still zero size
function delayedInitMap()
{
    if (map == null)
    {
        initMap();
        initMarkers();
        google.maps.event.trigger(map, 'resize');
    }
}

// hold details like div name and detailed template for each of the person, concept and place
var extraData;

// init details like div name and detailed template for each of the person, concept and place
// when ready to add events, add event hash to this hash, and add function to initialize event data
function initConfigHash()
{
    extraData = {
        'person': {'name': 'person', 'tabId': '#tab3',
            'divId': '#peopleDiv',
            'detailTemplate': "<h4>{{name}}</h4>" +
                              "<h5>Description:</h5><div class='elementDescription'>{{description}}</div>" +
                              "<div class='elementLink>'><h5>Link:</h5> <a href='{{link}}' target='_blank'>{{link}}</a></div>" +
                              "{{#image_link}}<div class='description-image'><img src='{{image_link}}'></div>{{/image_link}}" +
                              "<h5 id='appearances_header'>Appearances in this interview:</h5><div id='{{type}}InternalReferences'></div>" +
                              "<h5 id='also_mentioned_header'>Also mentioned in these other items:</h5><div id='{{type}}ExternalReferences'></div>" +
                              "<div class='description-link'>" +
                                "<a href='javascript:requestShowList(\"{{type}}\")'><i class='icon-chevron-left'></i>Show {{type}} list</a>" +
                              "</div>"},

        'concept': {'name': 'concept', 'tabId': '#tab5',
            'divId': '#conceptsDiv',
            'detailTemplate': "<h4>{{name}}</h4>" +
                              "<h5>Description:</h5><div class='elementDescription'>{{description}}</div>" +
                              "<div class='elementLink>'><h5>Link:</h5> <a href='{{link}}' target='_blank'>{{link}}</a></div>" +
                              "{{#image_link}}<div class='description-image'><img src='{{image_link}}'></div>{{/image_link}}" +
                              "<h5 id='appearances_header'>Appearances in this interview:</h5><div id='{{type}}InternalReferences'></div>" +
                              "<h5 id='also_mentioned_header'>Also mentioned in these other items:</h5><div id='{{type}}ExternalReferences'></div>" +
                              "<div class='description-link'>" +
                               "<a href='javascript:requestShowList(\"{{type}}\")'><i class='icon-chevron-left'></i>Show {{type}} list</a>" +
                               "</div>"},

        'place': {'name': 'place', 'tabId': '#tab4',
            'divId': '#placesDiv',
            'detailTemplate': "<h4>{{name}}</h4>" +
                              "<h5>Description:</h5><div class='elementDescription'>{{description}}</div>" +
                              "<div class='elementLink>'><h5>Link:</h5> <a href='{{link}}' target='_blank'>{{link}}</a></div>" +
                              "{{#image_link}}<div class='description-image'><img src='{{image_link}}'></div>{{/image_link}}" +
                              "<h5 id='appearances_header'>Appearances in this interview:</h5><div id='{{type}}InternalReferences'></div>" +
                              "<h5 id='also_mentioned_header'>Also mentioned in these other items:</h5><div id='{{type}}ExternalReferences'></div>" +
                              "<div class='description-link'>" +
                                "<a href='javascript:requestShowList(\"{{type}}\")'><i class='icon-chevron-left'></i>Show {{type}} list</a>" +
                              "</div>"}
    };
}

var elements = [];


// augment the database records for a people etc. with their type
// we need this since all elements are eventually put into a single array
//   and we will want to know which are people, which are concepts and which are places
function addType(array, type)
{
    for (var i = 0 ; i < array.length ; i++)
    {
        var currentHash = array[i];
        currentHash.type = type;
    }
}



// populate the people, concepts and places tabs with a list
function initTabs()
{
    initTabsAux("person");
    initTabsAux("concept");
    initTabsAux("place");
}

// add list of elements to corresponding ui tab
function initTabsAux(type)
{
    var elementTemplate = "{{#.}}<a href='javascript:requestShowElement(\"{{name}}\")'>{{name}}</a><br/>{{/.}}";
    if (type == 'place')
        elementTemplate = "<h4>Location Index</h4>" + elementTemplate;

    var configHash = extraData[type];
    var text = Mustache.render(elementTemplate, configHash.data);
    configHash.listHtml = text;     // save list so we can switch back to it
    jQuery(configHash.divId).html(text);
}

function showElementFromAnnotation(e)
{
    name = $(e.target).data('annotation').tags[0]
    showElement(name);
}
var map_initally_loaded = false
// display the element corresponding to the passed name in the proper tab
// make ajax requests to fetch references to the passed name, both in this pid and for other pids
function showElement(name, forceList)
{
    name = decodeURI(name);
    var element = getElement(name);
    if (element == null)
        return;
    var type = element.type;
    var configHash = extraData[type];

    var div = jQuery(configHash.divId);
    var template = configHash.detailTemplate;
    var text = Mustache.render(template, element);
    div.html(text);
    if (type == "place") {
        showLocationIndex();

    }

    clearReferences(type);

    var pid = getPidFromUrl();
    tabWithoutHistory = true;
    jQuery(configHash.tabId).click();     // show the right tab
    if (type == "place") {
      showMapCanvas(true);
      delayedInitMap();
      var latitude = element.latitutde;
             var longitude = element.longitude;
               var position = new google.maps.LatLng(latitude, longitude);
               //var latlngbounds = new google.maps.LatLngBounds();

               //if (latitude != -9999 && longitude != -9999)
               //{
               //      latlngbounds.extend(position);
               //}
               //    addListener(marker);
               //}

               //center the map around the markers and adjust zoom
            google.maps.event.addListenerOnce(map, 'idle', function(){
                // do something only the first time the map is loaded
                map.setCenter(position);
                map.setZoom(locationTypeToZoomLevel(element.location_type));
                map_initally_loaded = true
            });

           if (map_initally_loaded)
           {
               map.setCenter(position);
               map.setZoom(locationTypeToZoomLevel(element.location_type));
           }




    }
    tabWithoutHistory = false;
    // ajax back to server to get where this term appears in this and other interviews
    var url = "/catalog/get_external_references/" + pid + "/" + name;
    jQuery.ajax({type: "GET",
        url: url
    }).done(function(response){showExternalReferences(response, type)});

    url = "/catalog/get_internal_references/" + pid + "/" + name;
    jQuery.ajax({type: "GET",
        url: url
    }).done(function(response){
            showInternalReferences(response, type);

        });
}


// clear the divs that hold internal and external references
function clearReferences(type)
{
    var divName = '#' + type + "ExternalReferences";
    var div = jQuery(divName);
    div.html("");
    divName = '#' + type + "InternalReferences";
    div = jQuery(divName);
    div.html("");
}

// process external references from ajax request
//https://corpora.tufts.edu/catalog/tufts:MS165.002.001.00001?timestamp/31:29
function showExternalReferences(response, type)
{
    //var referenceTemplate = "{{#.}}{{title}} ({{count}})<br/>{{/.}}";
    //http://localhost:3000/catalog/tufts:sample.audio.01?timestamp/2:49
    var bubbleTemplate = "{{#.}}<a style=\"padding-left: 20px;\" class=\"transcript_link\" href='/catalog/{{pid}}?timestamp/{{display_time}}'>{{display_time}}</a>"+
                    "<div id='internalReferenceText{{time}}' style='padding-left: 20px; height:1.5em; overflow:hidden'>{{&text}}</div>" +
                    "<a href='javascript:showInternalReferenceMore(\"{{time}}\")'><div style='padding-left: 20px; padding-bottom: 10px; display:block' id='internalReferenceMore{{time}}' class='show-more'>Show more</div></a>{{/.}}";

    var bubble_text = '';

//    if(response[0] !== undefined && response[0].bubble !== undefined){
 //       bubble_text = Mustache.render(bubbleTemplate, response[0].bubble);
  //  }



    var referenceTemplate = "{{#.}}<div><a class=\"transcript_chunk_link\" href='/catalog/{{id}}'>{{title}} ({{count}})</a>" +
			    "<span class=\"collection_panel\" style='padding-left: 20px; display:block'>collection: {{collection}}</span>" +
                "<span class=\"external_segments_panel\" style='display:none'>"+
                "{{#bubble}}<a style=\"padding-left: 20px;\" class=\"transcript_link\" href='/catalog/{{pid}}?timestamp/{{display_time}}'>{{display_time}}</a>" +
                "<div id='internalReferenceText{{time}}' style='padding-left: 20px; height:1.5em; overflow:hidden'>{{text}}</div>" +
                "<a href='javascript:showInternalReferenceMore(\"{{time}}\")'><div style='padding-left: 20px; padding-bottom: 10px; display:block' id='internalReferenceMore{{time}}' class='show-more'>Show more</div></a>" +
                "{{/bubble}}" +
                "</span></div></div>{{/.}}";
    var text = Mustache.render(referenceTemplate, response);



    var divName = '#' + type + "ExternalReferences";
    var div = jQuery(divName);
    if (response.length > 0)
    {

        div.html(text);

    }
    else
    {
        jQuery('#also_mentioned_header').hide();
        div.hide();
    }
    $('.transcript_chunk_link').on("click", function(e) {
           e.preventDefault();
           $(e.currentTarget).siblings('.collection_panel').slideToggle();
           var external_segment = $(e.currentTarget).siblings('.external_segments_panel')
           //.toggle();
           external_segment.slideToggle('medium', function() {
            if (external_segment.is(':visible'))
                external_segment.css('display','inline-block');
        });

       });




}


// process internal references from ajax request
function showInternalReferences(response, type)
{
    var referenceTemplate = "{{#.}}{{#display_time_ssim}}<div class=\"internal_transcript_chunk_link\" data-time='{{start_in_milliseconds}}'>{{display_time_ssim}}</div>{{/display_time_ssim}}  <div id='internalReferenceText{{segmentNumber}}' style='height:1.5em; overflow:hidden'>{{&text}}</div>" +
        "<a href='javascript:showInternalReferenceMore(\"{{segmentNumber}}\")'><div id='internalReferenceMore{{segmentNumber}}' class='show-more'>Show more</div></a><br/>{{/.}}";
    text = Mustache.render(referenceTemplate, response);
    divName = '#' + type + "InternalReferences";
    div = jQuery(divName);
    div.html(text);
    $('.internal_transcript_chunk_link').on("click", function(e) {
        var t = $(e.currentTarget).data('time')
        jumpPlayerTo(t);
    });
}

// handle calls to the show more/show less button on internal references
function showInternalReferenceMore(id)
{
    var textElement = jQuery("#internalReferenceText" + id);
    var moreElement = jQuery("#internalReferenceMore" + id);
    if (moreElement.text() == "Show more")
    {
        textElement.css("height", "auto");    // show all the text
        moreElement.text("Show less");
    }
    else
    {
        textElement.css("height", "1.5em");   // show just the first line
        textElement.css("overflow", "hidden");
        moreElement.text("Show more");
    }
}

// show the list of elements based on the passed type: person, concept or place
function showList(type)
{
    var configHash = extraData[type];
    var listHtml = configHash.listHtml;    // use the html list of elements we previously saved
    var div = jQuery(configHash.divId);
    div.html(listHtml);
    var configHash = extraData[type];
    jQuery(configHash.tabId).click();
    if (type == 'place')
        map_initally_loaded = true
}



// return the element hash that represents a database row
function getElement(name)
{
    return getItem(name, elements);
}

// iterate over all the elements in the array looking for the passed name
// should we use a hash rather than this slow iteration
function getItem(name, array)
{
    for (var i = 0 ; i < array.length ; i++)
    {
        var element = array[i];
        if (element.name == name)
            return element;
    }
    return null;
}


// get all the divs holding transcript text and annotate them via a regular expression
function annotateTranscript()
{
    var utterances = jQuery(".transcript_utterance");
    var regex$ = createRegex(elements);
    var regex = new RegExp(regex$, 'g');
    for (var i = 0 ; i < utterances.length ; i++)
    {
        var utterance = utterances[i];
        var originalText = utterance.innerHTML;
        var annotatedText = originalText.replace(regex, "<a href='javascript:requestShowElement(\"$1\")'>$1</a>");
        utterance.innerHTML = annotatedText;
    }

}


// build a regular expression based on passed records
// passed records is an array of hashes for people, places or concepts
function createRegex(records)
{
    var regex =  "\\b(";
    for (var i = 0 ; i < records.length ; i++)
    {
        var element = records[i];
        var name = element.name;
        regex += name;
        regex += "|";
    }
    regex = regex.substr(0, regex.length - 1); // remove last |
    regex += ")\\b";
    return regex;
};

// below is code to deal with the map
// should it be in this file?

var map = null;

function initMap()
{
    var mapOptions = {
        center: new google.maps.LatLng(42., -71.),
        zoom: 7,
        mapTypeId: google.maps.MapTypeId.HYBRID,
        zoomControl: true,
        panControl: true,
        scaleControl: true
    };
    map = new google.maps.Map(document.getElementById("mapCanvas"), mapOptions);


}

// display the list (index) of places, not the map
function showLocationIndex()
{
    jQuery("#mapParent").hide();
    jQuery("#placesParentDiv").show();
}

// display the map, not the list of places
function showMapCanvas(showDetails)
{
    if (!showDetails) {
    jQuery("#placesParentDiv").hide();
    }
    jQuery("#mapParent").show();
    // the resize can throw an error but it is needed
    try
    {
        google.maps.event.trigger(map, 'resize');
    }
    catch (err)
    {

    }
}


// iterate over global "places" var and create a marker for each
function initMarkers()
{
    var places = extraData.place.data;
    var latlngbounds = new google.maps.LatLngBounds();

    for (var i = 0 ; i < places.length ; i++)
    {
        var place = places[i];
        var latitude = place.latitutde;
        var longitude = place.longitude;
        var name = place.name;
        var position = new google.maps.LatLng(latitude, longitude);
        var marker = new google.maps.Marker({
            position: position,
            map: map,
            title: name});
        if (latitude != -9999 && longitude != -9999)
        {
          console.log('lat :' + latitude);
          console.log('long :' + longitude);
          latlngbounds.extend(position);
        }
        addListener(marker);
    }

    //center the map around the markers and adjust zoom
   // map.setCenter(latlngbounds.getCenter());
    map.fitBounds(latlngbounds);
    // map.setZoom(locationTypeToZoomLevel(element.location_type));

}

// when user clicks on a map marker, display an info window
function markerClickHandler(marker)
{
    var name = marker.getTitle();
    highlightMapByName(name);
}

// highlight the passed name on the map by displaying an info window
function highlightMapByName(name)
{
    var element = getElement(name);
    if (name == null)
      return;
    var template = "<div class='infoWindow' style='width:250px'>Name: {{name}}<br/>Description: {{description}}<br><a href='javascript:requestShowElement(\"{{name}}\", true)'>More Info</a></div>";
    var text = Mustache.render(template, element);
    infoWindow = new google.maps.InfoWindow();
    infoWindow.setContent(text);
    infoWindow.setPosition(new google.maps.LatLng(element.latitutde, element.longitude));
   // map.setZoom(locationTypeToZoomLevel(element.location_type));
    infoWindow.open(map);

}

// get the pid from the browser's current url
// is there a better way to obtain it?
function getPidFromUrl()
{
    var path = window.location.pathname;
    var slash = path.lastIndexOf('/');
    if (slash == -1)
      return 'error in getPidFromUrl';
    return path.substr(slash + 1);
}

function addListener(marker)
{
    google.maps.event.addListener(marker, 'click', function (event) {markerClickHandler(marker)});
}

// return an appropriate map zoom level based on the passed type of location (e.g, university, continent)

function locationTypeToZoomLevel(passedLocationType)
{
    var zoomLevel = 7;
    if ((passedLocationType == "continent") || (passedLocationType == "ocean"))
        zoomLevel = 4;
    else if ((passedLocationType == "country"))
        zoomLevel = 5;
    else if ((passedLocationType == "university") || (passedLocationType == "business") || (passedLocationType == "college/university")
|| (passedLocationType == "library")
    || (passedLocationType == "military base")
|| (passedLocationType == "private school"))
    zoomLevel = 15;
else if ((passedLocationType == "residence")|| (passedLocationType == "building/structure")
    || (passedLocationType == "neighborhood") || (passedLocationType == "railway station")
    || (passedLocationType == "church")
    || (passedLocationType == "institution") || (passedLocationType == "hostel") || (passedLocationType == "hospital")
    || (passedLocationType == "bazar/market")
    || (passedLocationType == "museum") || (passedLocationType == "night club") || (passedLocationType == "holy site")
    || (passedLocationType == "government building") || (passedLocationType == "road") || (passedLocationType == "recreation"))
    zoomLevel = 17;
else if ((passedLocationType == "city/town") || (passedLocationType == "capital") || (passedLocationType == "lake"))
    zoomLevel = 11;
else if ((passedLocationType == "region") || (passedLocationType == "state") || (passedLocationType == "island")
    || (passedLocationType == "territory")
    || (passedLocationType == "district"))
    zoomLevel = 6;
    return zoomLevel;
}
