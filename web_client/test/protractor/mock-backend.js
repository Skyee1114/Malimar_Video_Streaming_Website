module.exports.httpBackendMock = function () {
  angular.module('httpBackendMock', ['tv-dashboard', 'ngMockE2E'])
    .run(function ($httpBackend) {

      $httpBackend.whenGET('/episodes/HaYaTe89-Feb-2015?show=HaYaTe').respond(function (){
        return [200,
          {
            "episodes":
              {
                "stream_url": "http://stream_url/example.com",
                "synopsis": "",
                "cover_image":
                  {
                    "sd": "http://sd_image.com",
                    "hd": "http://hd_image.com"
                  },
                "title": "Ha Ya Te | Episode 8 | Feb 09, 2015"
              }
          }
        ];
      });

      $httpBackend.whenGET('/thumbnails?container=HaYaTe').respond(function (){
        return [200,
          {
            "thumbnails":[
              {
                "id":"HaYaTe318-Jan-2015",
                "title":"Ha Ya Te | Episode 3  | Jan 18, 2015",
                "cover_image":
                  {
                    "sd":"http://images.malimartv.com/HaYaTe.jpg",
                    "hd":"http://images.malimartv.com/HaYaTeHD.jpg"
                  },
                "href":"http://localhost:3000/episodes/HaYaTe318-Jan-2015?show=HaYaTe",
                "type":"episode"
              },
              {
                "id":"HaYaTe212-Jan-2015",
                "title":"Ha Ya Te | Episode 2  | Jan 12, 2015",
                "cover_image":
                  {
                    "sd":"http://images.malimartv.com/HaYaTe.jpg",
                    "hd":"http://images.malimartv.com/HaYaTeHD.jpg"
                  },
                "href":"http://localhost:3000/episodes/HaYaTe212-Jan-2015?show=HaYaTe",
                "type":"episode"
              },
              {
                "id":"HaYaTe111-Jan-2015",
                "title":"Ha Ya Te | Episode 1  | Jan 11, 2015",
                "cover_image":
                  {
                    "sd":"http://images.malimartv.com/HaYaTe.jpg",
                    "hd":"http://images.malimartv.com/HaYaTeHD.jpg"
                  },
                "href":"http://localhost:3000/episodes/HaYaTe111-Jan-2015?show=HaYaTe",
                "type":"episode"
              }
            ]
          }
        ];
      });
    });
};
