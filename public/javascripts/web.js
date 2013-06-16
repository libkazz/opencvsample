$(function() {
  var capture_wared_photo = function(){
    console.log("capture photo");
    html2canvas($("#photo")[0], {
      onrendered: function(canvas){
        share_wared_photo(canvas);
      },
      logging: false
    });
  };

  var share_wared_photo = function(canvas) {
    console.log("shared photo: " + canvas);
    $.post('/share', { img : canvas.toDataURL('image/jpg') }, function(data){
      var src = JSON.parse(data)["src"];
      console.log("upload shared photo: " + src);

      $("#captures").append("<img src=\"" + src + "\" />");
    });
  };

  $("#share-button").click(function(){
    console.log("shared button clicked");
    capture_wared_photo();
  });
});
