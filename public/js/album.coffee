app = angular.module 'Album', ['ui']
app.config ($routeProvider) ->
  $routeProvider
    .when '/pages/:search_term/:page',
      templateUrl: 'partials/listing.html'
      controller: 'AlbumController'
      resolve:
        photos: ($q, $route, $timeout, $http) ->
          deferred = $q.defer()

          api_key = '2bb0b524a3e3cbb9ceaea74b30dabf93'
          url     = 'http://api.flickr.com/services/rest/'
          
          params =
            method: 'flickr.photos.search'
            api_key: api_key
            text: $route.current.params.search_term || localStorage.getItem('search_term') || 'thailand'
            per_page: 12
            format: 'json'
            page: $route.current.params.page || 1
            jsoncallback: 'JSON_CALLBACK'

          $http.jsonp(url, params: params).success (data, status, headers, config) ->
            page_info = {}
            page_info.page  = data.photos.page
            page_info.pages = data.photos.pages

            $location.path("/pages/1/#{$route.current.params.search_term}") if $route.current.params.page > page_info.pages

            photos = _.map data.photos.photo, (photo) ->
              title: photo.title
              thumb_src: "http://farm#{photo.farm}.staticflickr.com/#{photo.server}/#{photo.id}_#{photo.secret}_s.jpg"
              src: "http://farm#{photo.farm}.staticflickr.com/#{photo.server}/#{photo.id}_#{photo.secret}.jpg"

            deferred.resolve [page_info, photos]

          deferred.promise

    .otherwise
      redirectTo: "/pages/#{localStorage.getItem('search_term') || 'thailand'}/1"

app.controller 'AlbumController', ($scope, $http, $location, $routeParams, photos) ->

  per_page = 12
  
  $scope.photos      = photos[1]
  $scope.page        = photos[0].page
  $scope.pages       = photos[0].pages
  $scope.end         = $scope.page * per_page
  $scope.start       = $scope.end - (per_page - 1)
  $scope.search_term = $routeParams.search_term

  $scope.q           = $scope.search_term
      
  $scope.set_current_photo = (photo) ->
    $scope.title = photo.title
    $scope.current_photo = photo

  $scope.search = ->
    localStorage.setItem('search_term', $scope.q)
    $location.path("pages/#{$scope.q}/1")

  $scope.next_page = ->
    return if $scope.page >= $scope.pages
    $location.path("pages/#{$scope.search_term}/#{$scope.page + 1}")

  $scope.prev_page = ->
    return if $scope.page <= 1
    $location.path("pages/#{$scope.search_term}/#{$scope.page - 1}")

  $scope.$on '$viewContentLoaded', -> 
    $('#listing').focus()
  
  $scope.set_current_photo _.first $scope.photos 
