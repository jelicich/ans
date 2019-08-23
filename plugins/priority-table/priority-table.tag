<priority-table>

    <div class="DataTable">
        <div class="DataTable-header">
            <h1>Tabla de prioridad <span>para asignación de vuelos con viáticos en dólares</span></h1>
            <img src="https://www.andesonline.com/wp-content/themes/andes/images/logo.png">
        </div>
        <ol class="DataTable-table">
            <li class="DataTable-heading">
                <div>Nombre</div>
                <div>Grupo</div>
                <div>Viáticos</div>
                <div>Objetivo</div>
                <div>Diferencia</div>
                <div>
                    Compensaciones 
                    <span class="DataTable-description">(Licencia, Plan, Ingreso)</span>
                </div>
                <div>Diferencia Neta</div>
                <div show="{ showTempIndex }">Temp Index</div>
                <div>Prioridad</div>
            </li>
            <li each="{ tcp, idx in tcpList }" 
                show="{ (tcp.jefa && showJefas) || (!tcp.jefa && showAux) }" class="DataTable-row { 'is-blocked': tcp.isBlocked || tcp.inactiva } { idx % 2 ? 'even' : 'odd' }"
                onclick="{ toggleSelect }">
                <div>{ tcp.nombre }</div>
                <div class="{ tcp.jefa ? 'is-jefa' : 'is-aux' }">{ tcp.grupo }</div>
                <div>{ tcp.viaticos }</div>
                <div>{ tcp.groupTarget }</div> 
                <div>{ tcp.dif }</div>
                <div>{ tcp.planPlus }</div>
                <div>{ tcp.netDif }</div>
                <div show="{ showTempIndex }">{ tcp.tempIndex }</div>
                <div class="DataTable-priority">
                    <span class="badge" 
                        style="background-color: { colorScale(tcp.priorityIndex) }">
                        { tcp.priorityIndex }
                    </span>
                </div>

                <div if="{ tcp.isBlocked }" class="DataTable-tooltip">
                    Realizó un viaje dentro de los últimos {blockLimit} días
                    <div class="arrow-down"></div>
                </div>

                <div if="{ tcp.inactiva }" class="DataTable-tooltip">
                    TCP Inactiva
                    <div class="arrow-down"></div>
                </div>
            </li>
        </ol> 
        <div class="DataTable-controls">
            <label>
                <input type="checkbox" value="showJefas" checked="{ showJefas }" onchange="{ toggleTCP }">
                Mostrar Jefas
            </label>

            <label>
                <input type="checkbox" value="showAux" checked="{ showAux }" onchange="{ toggleTCP }">
                Mostrar Auxiliares
            </label>

            <input type="text" name="" placeholder="Filtrar por nombre" onkeyup="{ filter.bind(this) }">
        </div>
    </div>
        
    <style>
    
    </style>
    <script>
        
        var DIF_GROUP = andes.config[0].diferenciaentregrupos;
        var today = new Date();
        var startDate = andes.config[0].fechainicio; // date in which viaticos are being monitored
        var monthDiffViaticos = monthDiff(startDate, today);
        var lastJefasGroup = andes.config[0].ultimogrupojefas;
        var targetForNewTcp = andes.config[0].objetivonuevatcp;
        this.blockLimit = andes.config[0].ocultarpor;
        var scaleGroup;

        this.groups = [];
        this.showTempIndex = false;
        this.showJefas = true;
        this.showAux = true;

        this.on('mount', function() {
            this._tcpList = $.extend(true, [], opts.tcpList);
            this.createGroupsAndSetDif(this._tcpList);
            this.createScales();
            this.evaluateData(this._tcpList);
            sortList(this._tcpList, 'priorityIndex');
            this.tcpList = $.extend(true, [], this._tcpList);
            this.update();
            console.log(this.tcpList);

            // fix headings
            window.onscroll = function() {fixHeadings()};
            var headings = document.querySelector('.DataTable-heading');
            var sticky = headings.offsetTop;

            function fixHeadings() {
                isOff = window.pageYOffset > sticky;
                $(headings).toggleClass('is-fixed', isOff)
            }
        })

        /**
         * creates groups and sets min and max viaticos to each group
         * @param {Object} tcpList - tcp list data from google sheet (processed).
         */
        this.createGroupsAndSetDif = function(tcpList) {
            var maxViaticos = d3.extent(tcpList, function(d) { return d.viaticos; })[1];
            var minViaticos = d3.extent(tcpList, function(d) { return d.viaticos; })[0];
            var groupsLength = d3.extent(tcpList, function(d) { return d.grupo; })[1];

            var tempTargetViaticos = maxViaticos + DIF_GROUP;
            
            //populate group with dummy data
            for(var i = 0; i < groupsLength; i++) {
                this.groups.push({ 
                    target: tempTargetViaticos - DIF_GROUP * i,
                    min: maxViaticos,
                    max: minViaticos
                });
            }

            tcpList.forEach(function(tcp) {
                //set min max on each group
                var g = tcp.grupo - 1;
                this.groups[g].min = tcp.viaticos < this.groups[g].min ? tcp.viaticos : this.groups[g].min;
                this.groups[g].max = tcp.viaticos > this.groups[g].max ? tcp.viaticos : this.groups[g].max;

                //set dif to tcp
                tcp.dif = this.groups[g].target - tcp.viaticos;
            }.bind(this))
        }


        /**
         * creates scales used to get indexes 
         */
        this.createScales = function() {
            //scale used to get group index 
            //used to increase priority % (1 to 10%)
            scaleGroup = d3.scaleLinear();
            scaleGroup.domain(d3.extent(this._tcpList, function(d) { return d.grupo; }))
                .range([0.1, 0.01]);
        }

        /**
         * set extra data to tcp object and sets the temp priority index
         * @param {Object} tcp - tcp object with row info.
         */
        this.evaluateData = function(tcpList) {
            tcpList.forEach(function(tcp) {
                //copy group target to tcp object 
                tcp.groupTarget = this.groups[tcp.grupo-1].target;

                //set planPlus (average of viaticos to be added to the real viaticos) 
                var planPlus = 0;
                var monthlyAverage = this.getMonthlyAverage(tcp);
                if(tcp.licenciaplanactivo) {
                    var planDuration = monthDiff(tcp.iniciolicenciaplan, today);
                    planPlus += monthlyAverage * planDuration;
                }

                var hasPreviousPlan = !isNaN(parseInt(tcp.totallicenciasplanes));
                if(hasPreviousPlan) {
                    planPlus += monthlyAverage * tcp.totallicenciasplanes;
                }

                if(monthDiff(tcp.ingreso, today) < monthDiff(startDate, today)) {
                    var startDif = monthDiff(startDate, today) - monthDiff(tcp.ingreso, today);
                    planPlus += monthlyAverage * startDif;

                    //set target to 0.8 * month when tcp.ingreso is lower than a year
                    if(monthDiff(tcp.ingreso, today) < 12) {
                        tcp.groupTarget = targetForNewTcp * monthDiff(tcp.ingreso, today);
                        tcp.dif = tcp.groupTarget - tcp.viaticos;
                        console.log(tcp)
                    } 
                } 
                
                tcp.planPlus = planPlus.toFixed(2);

                tcp.netDif = (tcp.dif - planPlus).toFixed(2);

                tcp.tempIndex = (tcp.dif - planPlus) * (1 + scaleGroup(tcp.grupo));

                //extra info
                tcp.jefa = tcp.grupo <= lastJefasGroup;
                
                tcp.isBlocked = tcp.ultimovuelo && dayDiff(tcp.ultimovuelo, today) < this.blockLimit;

            }.bind(this))

            this.setPriorityIndex(tcpList);
        }

        /**
         * set de priority index. evaluates all the tempIndex 
         * and scale them from 0 to 100 
         * @param {Object} tcpList - tcp list data from google sheet (processed).
         */ 

        this.setPriorityIndex = function(tcpList) {
            //scale to get the priority where 100 is higher priority and 0 lowest
            var scale = d3.scaleLinear();
            scale.domain(d3.extent(tcpList, function(d) { return d.tempIndex; }))
            .range([0, 100]);

            tcpList.forEach(function(tcp) {
                if(!tcp.inactiva) {
                    tcp.priorityIndex = Math.round(scale(tcp.tempIndex));
                    //tcp.tempIndex = Math.round(scale(tcp.tempIndex));
                } else {
                    tcp.priorityIndex = 0;
                }
                
            })
        }

        /**
         * get monthly viaticos average by tcp and their group
         * @param {Object} tcp - tcp row object
         */
        this.getMonthlyAverage = function(tcp) {
            var g = tcp.grupo - 1;
            var average = (this.groups[g].max + this.groups[g].min) / 2;
            var monthlyAverage = average / monthDiffViaticos;
            return monthlyAverage;
        }

        /**
         * toggle jefas and aux from the list
         * @param {Event} event
         */
        this.toggleTCP = function(event) {
            var value = event.target.value;
            this[value] = event.target.checked;
            this.update();
        }

        /**
         * highlight the row
         * @param {Event} event
         */
        this.toggleSelect = function(event) {
            var $row = $(event.currentTarget);
            $row.toggleClass('is-selected')
        }

        /**
         * filter the table by name
         * @param {Event} event
         */
        this.filter = function(event) {
            if(event.target.value.length > 2) {
                this.tcpList = this._tcpList.filter(function(tcp){
                    return checkName(tcp, event.target.value.toLowerCase())
                })
                this.update();
            } else if(event.target.value.length == 0) {
                this.tcpList = $.extend(true, [], this._tcpList);
                this.update();
            }
        }

        this.colorScale = function(value) {
            return d3.scaleLinear().domain([0,100])
                .interpolate(d3.interpolateHcl)
                .range([d3.rgb('#1eaa3c'), d3.rgb('#aa1e1e')])(value);
        }

        function checkName(tcp, query) {
            var name = tcp.nombre.toLowerCase();
            return name.indexOf(query) > -1;
        }

        /**
         * get month difference between two dates
         * @param {Date} d1 - date object
         * @param {Date} d2 - date object
         */
        function monthDiff(d1, d2) {
            var months;
            months = (d2.getFullYear() - d1.getFullYear()) * 12;
            months -= d1.getMonth() + 1;
            months += d2.getMonth();
            return months <= 0 ? 0 : months;
        }

        /**
         * get day difference between two dates
         * @param {Date} d1 - date object
         * @param {Date} d2 - date object
         */
        function dayDiff(d1, d2) {
            var diffTime = Math.abs(d2.getTime() - d1.getTime());
            var diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)); 
            return diffDays;
        }

        function sortList(tcpList, property) {
            tcpList.sort(function(a, b) {
                return parseFloat(a[property]) - parseFloat(b[property]);
            }).reverse();
        }
    </script>
</priority-table>