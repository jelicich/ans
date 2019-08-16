<priority-table>
	<ol class="tcp-table">
		<li class="headers">
			<div>Nombre</div>
			<div>Grupo</div>
			<div>Viaticos</div>
			<div>Objetivo</div>
			<div>Diferencia</div>
			<div>Compensacion por lic.</div>
			<div>Diferencia Neta</div>
			<div>Prioridad</div>
		</li>
		<li each="{ tcp in tcpList }">
			<div>{ tcp.name }</div>
			<div>{ tcp.group }</div>
			<div>{ tcp.payments }</div>
			<div>{ gruop[tcp.group-1].target }</div>
			<div>{ tcp.dif }</div>
			<div>{ tcp.plan }</div>
			<div>{ tcp.planDif }</div>
			<div>{ tcp.priority }</div>
		</li>
	</ol>
	<script>
		
	</script>
</priority-table>