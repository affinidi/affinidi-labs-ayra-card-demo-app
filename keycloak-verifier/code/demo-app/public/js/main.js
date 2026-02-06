// Check VC-AuthN status on page load
document.addEventListener('DOMContentLoaded', async () => {
  try {
    const response = await fetch('/health');
    const data = await response.json();

    if (data.status === 'healthy') {
      console.log('✅ Demo App is healthy');
      console.log('📋 Keycloak:', data.keycloak);
    }
  } catch (error) {
    console.error('❌ Failed to check app status:', error);
  }
});

// Add smooth scrolling
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
  anchor.addEventListener('click', function (e) {
    e.preventDefault();
    const target = document.querySelector(this.getAttribute('href'));
    if (target) {
      target.scrollIntoView({
        behavior: 'smooth',
        block: 'start'
      });
    }
  });
});
