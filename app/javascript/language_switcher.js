// Language switcher functionality
document.addEventListener('DOMContentLoaded', function() {
  // Find all language switch links
  const languageSwitchers = document.querySelectorAll('.js-language-switch');
  
  // Attach click handlers to each language switch link
  languageSwitchers.forEach(function(link) {
    link.addEventListener('click', function(e) {
      e.preventDefault();
      
      // Get the target locale from the data attribute
      const targetLocale = this.getAttribute('data-locale');
      
      // Get CSRF token
      const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
      
      // Use fetch API to set the locale without form submission
      fetch('/set_locale', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken
        },
        body: JSON.stringify({ locale: targetLocale }),
        credentials: 'same-origin' // This ensures cookies are sent with the request
      }).then(response => {
        if (response.ok) {
          // Reload the page to show content in new language
          window.location.reload();
        } else {
          console.error('Failed to set locale');
        }
      }).catch(error => {
        console.error('Error setting locale:', error);
      });
    });
  });
});