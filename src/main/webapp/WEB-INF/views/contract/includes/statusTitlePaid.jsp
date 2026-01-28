<%-- PAID 상태 집계 (클라이언트용) --%>
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
        ✅ 최종 승인 대기 (지급 요청 대기: ${totalRequested}건)
    </c:when>
    <c:when test="${totalDeposited > 0}">
        ✅ 최종 승인 대기 (입금 완료: ${totalDeposited}건)
    </c:when>
    <c:when test="${totalPaid > 0}">
        ✅ 최종 승인 대기 (지급 진행 중: ${totalPaid}/${totalMilestones})
    </c:when>
    <c:otherwise>
        ✅ 최종 승인 대기
    </c:otherwise>
</c:choose>
