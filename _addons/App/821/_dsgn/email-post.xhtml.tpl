<?xml version="1.0" encoding="UTF-8"?>
<template>
	<header>
		<extend level="auto" name="email" />
	</header>
	
	<entity id="email.plain" replace_variables="true">
		<![CDATA[
<%main-title%>
<%main-desc%>

<#email.content#>
		]]>
	</entity>
	
</template>
