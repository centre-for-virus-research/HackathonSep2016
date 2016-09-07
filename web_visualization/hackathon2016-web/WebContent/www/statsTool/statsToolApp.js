var statsToolApp = angular.module('statsToolApp', []);


statsToolApp.controller('statsToolCtrl', 
  [ '$scope', '$http',
function ($scope, $http) {

	  console.log("retrieving sequence metrics");
	  $http.get("../../../hackathon2016/sequenceMetrics")
	    .success(function(data, status, headers, config) {
			  console.info('success', data);
			  $scope.sequenceMetrics = data.sequenceMetrics;
			  $scope.xMetric = $scope.sequenceMetrics[0];
			  console.log("xMetric", $scope.xMetric);
			  $scope.yMetric = $scope.sequenceMetrics[1];
			  console.log("yMetric", $scope.yMetric);

	    })
	    .error(function(data, status, headers, config) {
			  console.info('error', data);
	    });

		$scope.$watch( 'currentSample', function(newObj, oldObj) {
			$scope.currentSampleChanged();
		}, false);

	  
		  console.log("retrieving samples");
		  $http.get("../../../hackathon2016/samples")
		    .success(function(data, status, headers, config) {
				  console.info('success', data);
				  $scope.samples = data.samples;
				  $scope.currentSample = $scope.samples[0];
				  console.log("samples", $scope.samples);

		    })
		    .error(function(data, status, headers, config) {
				  console.info('error', data);
		    });

	  $scope.currentSampleChanged = function() {
		  $scope.sequences = null;
		  if($scope.currentSample == null)  {
			  return;
		  }
		  console.log("retrieving sequences");
		  $http.post("../../../hackathon2016/sequences", 
				  {sampleId: $scope.currentSample.id})
		    .success(function(data, status, headers, config) {
				  console.info('success', data);
				  $scope.sequences = data.sequences;
				  $scope.currentSequence = $scope.sequences[0];
				  console.log("samples", $scope.samples);

		    })
		    .error(function(data, status, headers, config) {
				  console.info('error', data);
		    });
	  };
	  
	  
	  $scope.getContigs = function() {
		  var requestObj = {
				  sequenceId: $scope.currentSequence.sequenceId, 
				  xMetric: $scope.xMetric.property, 
				  yMetric: $scope.yMetric.property 
		  };
		  console.log("Updating for request", requestObj);
		  $http.post("../../../hackathon2016/getContigs", requestObj)
		  .success(function(data, status, headers, config) {
			  console.info('success', data);
		  })
		  .error(function(data, status, headers, config) {
			  console.info('error', data);
		  });
	  }
	  
  } ]);


