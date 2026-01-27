<%-- PAID 상태 집계 (프리랜서용) --%>
<c:set var="totalRequested" value="0"/>
<c:set var="totalDeposited" value="0"/>
<c:set var="totalPaid" value="0"/>
<c:set var="totalMilestones" value="0"/>
<c:forEach var="contract" items="${statusEntry.value}">
    <c:if test="${contract.requestedMilestones != null}">
        <c:set var="totalRequested" value="${totalRequested + contract.requestedMilestones}"/>
    </c:if>
    <c:if test="${contract.depositedMilestones != null}">
        <c:set var="totalDeposited" value="${totalDeposited + contract.depositedMilestones}"/>
    </c:if>
    <c:if test="${contract.paidMilestones != null}">
        <c:set var="totalPaid" value="${totalPaid + contract.paidMilestones}"/>
    </c:if>
    <c:if test="${contract.totalMilestones != null}">
        <c:set var="totalMilestones" value="${totalMilestones + contract.totalMilestones}"/>
    </c:if>
</c:forEach>
<c:choose>
    <c:when test="${totalRequested > 0}">
        💰 결제 완료 (지급 요청 중: ${totalRequested}건 - 클라이언트 승인 대기)
    </c:when>
    <c:when test="${totalDeposited > 0}">
        💰 결제 완료 (에스크로 입금 완료: ${totalDeposited}건 - 지급 요청 가능)
    </c:when>
    <c:when test="${totalPaid > 0}">
        💰 결제 완료 (수령 진행 중: ${totalPaid}/${totalMilestones})
    </c:when>
    <c:otherwise>
        💰 결제 완료 (수령 대기 중)
    </c:otherwise>
</c:choose>
