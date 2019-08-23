(function(){
    'use strict';

    var andes = window.andes = $.extend(window.andes, {
        data: null,
        config: null,

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
            var urlData = 'https://spreadsheets.google.com/feeds/list/' + SHEET_ID + '/1/public/full?alt=json';
            var urlConfig = 'https://spreadsheets.google.com/feeds/list/' + SHEET_ID + '/2/public/full?alt=json';
            
            $.getJSON(urlConfig, function(config) {
                //console.log(config.feed.entry)
                andes.processAndSetData(config.feed.entry, 'config');

                $.getJSON(urlData, function(data) {    
                    //console.log(data.feed.entry);
                    andes.processAndSetData(data.feed.entry, 'data');
                    callback();
                });
            })
                
        },

        processAndSetConfig: function(googleFeed) {
            var COL_PREFIX = 'gsx$';
            var CELL_PREFIX = '$t';
            console.log(googleFeed);
        },

        processAndSetData: function(googleFeed, propertyName) {
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
                        
                        var value;

                        //parse values
                        switch(property) {
                            //dates
                            case 'ingreso':
                            case 'ingresojefa':
                            case 'iniciolicenciaplan':
                            case 'ultimovuelo':
                            case 'fechainicio':
                                if(row[column][CELL_PREFIX].length > 0) {
                                    var dateParts = row[column][CELL_PREFIX].split("/");
                                    // month is 0-based, that's why we need dataParts[1] - 1
                                    value = new Date(+dateParts[2], dateParts[1] - 1, +dateParts[0]);
                                } else {
                                    value = null;
                                }
                                break;
                            
                            //numbers
                            case 'grupo':
                            case 'totallicenciasplanes':
                            case 'viaticos':
                            case 'diferenciaentregrupos':
                            case 'ocultarpor':
                            case 'ultimogrupojefas':
                            case 'objetivonuevatcp':
                                value = row[column][CELL_PREFIX].length > 0 ? parseFloat(row[column][CELL_PREFIX]) : null;
                                break;

                            //boolean
                            case 'licenciaplanactivo':
                            case 'inactiva':
                                value = eval(row[column][CELL_PREFIX].toLowerCase());
                                break;

                            default:
                                value = row[column][CELL_PREFIX];
                        }

                        cleanRow[property] = value;
                    }
                }
                data.push(cleanRow);
            }
            //console.log(data);
            this[propertyName] = data;
        }
    });

    window.riot.observable(andes);

    $(document).ready(andes.init.bind(andes));
})();