(function(){
	'use strict';

	var andes = window.andes = $.extend(window.andes, {
		data:null,

		init: function() {
			
			// this.getData(function() {
			// 	console.log(data);
			// 	window.andes.data = data;
			// 	window.riot.mount('*');
			// })

			// this.getData().done(function(data) {
			// 	console.log(data);
			// 	window.andes.data = data;
			// 	window.riot.mount('*');

			// })

			this.getJSON();

		},

		getData: function(callback) {
			var KEY = 'AIzaSyArUhro5s5xTcU0RC3znxsHRLGqtso8Eto';
			var SHEET_ID = '1Smi_r5s0XwXTEjiMZTabVVFLZFef23BkxpXicIjoe6A';
			var URL = 'https://sheets.googleapis.com/v4/spreadsheets/' + SHEET_ID + '/values/Sheet1!A1:H10?key=' + KEY;

			return $.ajax({
			    url:URL,
			    dataType:"jsonp",
			});

		},

		getJSON: function(callback) {
			var SHEET_ID = '1Smi_r5s0XwXTEjiMZTabVVFLZFef23BkxpXicIjoe6A';
			var PROXY = 'https://cors-anywhere.herokuapp.com/';
			$.getJSON('https://spreadsheets.google.com/feeds/list/' + SHEET_ID + '/od6/public/values?alt=json', function(data) {	
				console.log(data.feed.entry);
			});
		}
	});

	$(document).ready(andes.init.bind(andes));
})();