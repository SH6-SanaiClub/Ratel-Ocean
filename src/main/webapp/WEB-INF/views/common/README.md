# Common Headers and Dashboards (feature/common)

This folder contains shared JSP header fragments and guidance for including them across pages.

## Files
- `user_header.jsp`: Pre-login header (Ratel logo + brand name, simple nav)
- `freelancer_header.jsp`: Post-login freelancer header (3-column layout)
- `client_header.jsp`: Post-login client header (3-column layout, same design as freelancer, center menu differs)

## Include Usage
Add the fragment at the top of your JSP body. Do NOT set `contentType` in fragments to avoid conflicts; set it on the parent JSP.

```jsp
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
...
<%@ include file="/WEB-INF/views/common/user_header.jsp" %>
<%@ include file="/WEB-INF/views/common/freelancer_header.jsp" %>
<%@ include file="/WEB-INF/views/common/client_header.jsp" %>
```

## Layout Rules (freelancer/client)
The headers use strict 3-column flex layout to keep alignment identical:

```html
<header class="site-header">
  <div class="header-inner">
    <div class="header-left">  <!-- Ratel logo + brand name -->
    <div class="header-center"> <!-- Center nav (Queue logo + menu for freelancer, menu only for client) -->
    <div class="header-right">  <!-- Notifications / Chat / Profile -->
  </div>
</header>
```

- Height: 70px
- Background: `#2B2B2B`
- Max width: `1400px`
- Left/right areas identical between freelancer and client headers
- Center area differs as specified

## Required Assets
Place these under `src/main/webapp/resources/images/`:
- `ratelogo.png` (brand logo)
- `queuelogo.png` (freelancer center logo)
- `default_profile.png` (profile placeholder)

## Dashboards
- `dashboard.jsp`: Freelancer dashboard includes `freelancer_header.jsp`
- `client_dashboard.jsp`: Client dashboard includes `client_header.jsp`

Each dashboard sets `contentType="text/html;charset=UTF-8"` and `pageEncoding="UTF-8"` at the top.

## Notes
- Fragments declare only `pageEncoding="UTF-8"` to ensure correct character decoding.
- Parent pages control `contentType` and overall document encoding.
- Keep CSS inside each JSP `<style>` for simplicity; can be extracted later to a shared CSS.
