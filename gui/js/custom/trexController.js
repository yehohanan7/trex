var trex = angular.module('trex', []);

trex.controller('trexController', function ($scope) {

   var section = 'inprogress';
   $scope.section = function (id) {
         section = id;
   };

   $scope.is = function (id) {
      return section == id;
   };
});