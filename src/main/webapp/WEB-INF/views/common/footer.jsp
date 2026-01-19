<%@ page pageEncoding="UTF-8" %>
<% if (request.getAttribute("footerRendered") == null) { request.setAttribute("footerRendered", true); %>
<style>
.site-footer { background-color: #2B2B2B; border-top: 1px solid #3a3a3a; margin-top: auto; padding: 3rem 2rem; }
.footer-inner { max-width: 1400px; margin: 0 auto; display: flex; flex-direction: column; gap: 2rem; align-items: center; text-align: center; }
.footer-brand { display: flex; flex-direction: column; gap: 0.5rem; }
.footer-brand .service-name { font-size: 1.2rem; font-weight: 700; color: #94D9DB; letter-spacing: 0.06em; }
.footer-brand .service-tagline { font-size: 0.9rem; color: #b0b0b0; }
.footer-links { display: flex; gap: 2rem; justify-content: center; flex-wrap: wrap; }
.footer-links a { color: #b0b0b0; text-decoration: none; font-size: 0.9rem; transition: color 0.2s ease; }
.footer-links a:hover { color: #94D9DB; }
.footer-links .separator { color: #555; }
.footer-copyright { font-size: 0.85rem; color: #888; margin-top: 1rem; }
@media (max-width: 768px) { .site-footer { padding: 2rem 1.5rem; } .footer-inner { gap: 1.5rem; } .footer-links { gap: 1.5rem; } .footer-brand .service-name { font-size: 1.1rem; } .footer-brand .service-tagline { font-size: 0.85rem; } }
</style>
<footer class="site-footer">
  <div class="footer-inner">
    <div class="footer-brand">
      <div class="service-name">RATEL OCEAN</div>
      <div class="service-tagline">계약·정산 기반 협업 플랫폼</div>
    </div>
    <div class="footer-links">
      <a href="/ratelocean/policy/terms">이용약관</a>
      <span class="separator">|</span>
      <a href="/ratelocean/policy/privacy">개인정보처리방침</a>
    </div>
    <div class="footer-copyright">© 2026 SanaiClub. All rights reserved.</div>
  </div>
</footer>
<% } %>