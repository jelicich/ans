(function(){
    'use strict';

    var andes = window.andes = $.extend(window.andes, {
        data:null,

        init: function() {
            
            // this.getData(function() {
            //  console.log(data);
            //  window.andes.data = data;
            //  window.riot.mount('*');
            // })

            // this.getData().done(function(data) {
            //  console.log(data);
            //  window.andes.data = data;
            //  window.riot.mount('*');

            // })

            this.getSheetJSON(function() {
                //console.log(andes.data);
                window.riot.mount('*');
            });

        },

        getData: function(callback) {
            // var KEY = 'AIzaSyArUhro5s5xTcU0RC3znxsHRLGqtso8Eto';
            // var SHEET_ID = '1Smi_r5s0XwXTEjiMZTabVVFLZFef23BkxpXicIjoe6A';
            // var URL = 'https://sheets.googleapis.com/v4/spreadsheets/' + SHEET_ID + '/values/Sheet1!A1:H10?key=' + KEY;

            return $.ajax({
                url:URL,
                dataType:"jsonp",
            });

        },

        getSheetJSON: function(callback) {
            var SHEET_ID = '1Smi_r5s0XwXTEjiMZTabVVFLZFef23BkxpXicIjoe6A';
            var PROXY = 'https://cors-anywhere.herokuapp.com/';
            $.getJSON('https://spreadsheets.google.com/feeds/list/' + SHEET_ID + '/od6/public/values?alt=json', function(data) {    
                //console.log(data.feed.entry);
                andes.processAndSetData(data.feed.entry);
                callback();
            });
        },

        processAndSetData: function(googleFeed) {
            var COL_PREFIX = 'gsx$';
            var CELL_PREFIX = '$t';
            var data = [];
            for(var i = 0; i < googleFeed.length; i++) {
                var row = googleFeed[i];
                var cleanRow = {};
                for (var column in row) {   
                    var isValidCol = column.indexOf(COL_PREFIX) >= 0;
                    if(isValidCol) {
                        var property = column.substr(COL_PREFIX.length);
                        cleanRow[property] = row[column][CELL_PREFIX];
                    }
                }
                data.push(cleanRow);
            }
            //console.log(data);
            this.data = data;
        }
    });

    $(document).ready(andes.init.bind(andes));
})();