$(function() {
  var urls = [
    "http://www.ku-baseball.com/member/images/shimada_k.JPG",
    "http://r-center.grips.ac.jp/gallery/pics/small/%E5%B7%9D%E4%BA%BA%E5%85%88%E7%94%9F%E3%80%80%E5%86%99%E7%9C%9F_1341895835.jpg",
    "http://www.e-agora.jp/pics/DSCF0458.JPG",
    "http://www.mhiroto.com/wp/wp-content/uploads/2013/04/33875c866013bb35553ee3ca21df107c.jpg",
    "http://www.cocomo1.net/img/face/g/bofor.jpg",
    "http://amd.c.yimg.jp/im_siggvn_KdlOusQcFenzCFlLjsA---x341-y450-q90/amd/20130411-00000020-modelp-000-1-view.jpg",
    "http://developer.cybozu.co.jp/akky/wp-content/uploads/2013/01/sIMG_20130124_031010.jpg",
    "http://rr.img.naver.jp/mig?src=http%3A%2F%2Fimgcc.naver.jp%2Fkaze%2Fmission%2FUSER%2F2%2F7%2F227147%2F4025%2F387x426x6a8224a16e2d79bacd10ce2a.jpg%2F300%2F600&twidth=300&theight=600&qlt=80&res_format=jpg&op=r",
    "http://obaco.arrow.jp/img/img30_TKY200606210496.jpg",
    "http://fsimg.afloat.co.jp/fs2cabinet/gd2/gd2438/gd2438-m-01-dl.jpg",
    "http://www.asahi.com/eco/images/OSK200907100179.jpg",
    "http://dahpbpalpng0r.cloudfront.net/products/2_kadoya11-2/product/430_1_front.jpg",
  ];

  $("#url").autocomplete({source: urls});

  $("#capture-button").click(function(){
    html2canvas($("#photo")[0], {
      onrendered: function(canvas){
        $("#capture").append(canvas);
        // canvas.css("display", "none");
        $("#share-button").show();
      },
      logging: true
    });
  });

  var share_photo = function(canvas) {
    $.post('/share', { img : canvas.toDataURL('image/jpg') }, function(data){
      $("#capture").children().hide();
      console.log(data);
      var src = JSON.parse(data)["src"];
      console.log("upload shared photo: " + src);

      $("#captures").append("<img src=\"" + src + "\" />");
    });
  };

  $("#share-button").click(function(){
    share_photo($("#capture canvas")[0]);
  });
});
