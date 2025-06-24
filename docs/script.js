// fs-explore Documentation JavaScript

// Tab switching functionality
function showTab(tabName) {
    // Hide all tab contents
    const tabContents = document.querySelectorAll('.tab-content');
    tabContents.forEach(content => content.classList.remove('active'));
    
    // Remove active class from all buttons
    const tabButtons = document.querySelectorAll('.tab-btn');
    tabButtons.forEach(btn => btn.classList.remove('active'));
    
    // Show selected tab content
    const selectedTab = document.getElementById(tabName + '-tab');
    if (selectedTab) {
        selectedTab.classList.add('active');
    }
    
    // Add active class to clicked button
    const clickedButton = event.target;
    clickedButton.classList.add('active');
}

// Copy to clipboard functionality
async function copyToClipboard(text) {
    try {
        await navigator.clipboard.writeText(text);
        
        // Show feedback
        const btn = event.target;
        const originalText = btn.textContent;
        btn.textContent = '✅';
        btn.style.background = '#22c55e';
        
        setTimeout(() => {
            btn.textContent = originalText;
            btn.style.background = '';
        }, 2000);
        
    } catch (err) {
        console.error('Failed to copy text: ', err);
        
        // Fallback for older browsers
        const textArea = document.createElement('textarea');
        textArea.value = text;
        document.body.appendChild(textArea);
        textArea.select();
        
        try {
            document.execCommand('copy');
            
            // Show feedback
            const btn = event.target;
            const originalText = btn.textContent;
            btn.textContent = '✅';
            btn.style.background = '#22c55e';
            
            setTimeout(() => {
                btn.textContent = originalText;
                btn.style.background = '';
            }, 2000);
            
        } catch (fallbackErr) {
            console.error('Fallback copy failed: ', fallbackErr);
        }
        
        document.body.removeChild(textArea);
    }
}

// Smooth scrolling for anchor links
document.addEventListener('DOMContentLoaded', function() {
    const links = document.querySelectorAll('a[href^="#"]');
    
    links.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            
            const targetId = this.getAttribute('href').substring(1);
            const targetElement = document.getElementById(targetId);
            
            if (targetElement) {
                targetElement.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
});

// Add some interactive animations
document.addEventListener('DOMContentLoaded', function() {
    // Animate elements on scroll
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };
    
    const observer = new IntersectionObserver(function(entries) {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
            }
        });
    }, observerOptions);
    
    // Observe all cards
    const cards = document.querySelectorAll('.feature-card, .language-card, .usage-section');
    cards.forEach(card => {
        card.style.opacity = '0';
        card.style.transform = 'translateY(30px)';
        card.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
        observer.observe(card);
    });
});

// Add some fun terminal animation
document.addEventListener('DOMContentLoaded', function() {
    const cursor = document.querySelector('.cursor');
    const commands = [
        'home',
        'open main.lua',
        'fs-explore',
        '..',
        'quit'
    ];
    
    let currentCommand = 0;
    let currentChar = 0;
    let isTyping = true;
    
    function typeCommand() {
        if (!cursor) return;
        
        const command = commands[currentCommand];
        
        if (isTyping) {
            if (currentChar < command.length) {
                cursor.textContent = command.substring(0, currentChar + 1) + '_';
                currentChar++;
                setTimeout(typeCommand, 150);
            } else {
                isTyping = false;
                setTimeout(typeCommand, 2000);
            }
        } else {
            if (currentChar > 0) {
                cursor.textContent = command.substring(0, currentChar - 1) + '_';
                currentChar--;
                setTimeout(typeCommand, 100);
            } else {
                isTyping = true;
                currentCommand = (currentCommand + 1) % commands.length;
                setTimeout(typeCommand, 500);
            }
        }
    }
    
    // Start the animation after a delay
    setTimeout(typeCommand, 2000);
});

// Mobile touch enhancements
document.addEventListener('DOMContentLoaded', function() {
    // Improve touch scrolling on iOS
    document.body.style.webkitOverflowScrolling = 'touch';
    
    // Prevent zoom on double-tap for better UX
    let lastTouchEnd = 0;
    document.addEventListener('touchend', function(event) {
        const now = (new Date()).getTime();
        if (now - lastTouchEnd <= 300) {
            event.preventDefault();
        }
        lastTouchEnd = now;
    }, false);
    
    // Add visual feedback for touch interactions
    const interactiveElements = document.querySelectorAll('.tab-btn, .copy-btn, .download-btn, .mobile-download-btn, .btn-primary, .btn-secondary');
    
    interactiveElements.forEach(element => {
        element.addEventListener('touchstart', function() {
            this.style.opacity = '0.7';
        }, { passive: true });
        
        element.addEventListener('touchend', function() {
            setTimeout(() => {
                this.style.opacity = '';
            }, 150);
        }, { passive: true });
    });
});

// Optimize animations for mobile devices
function isMobileDevice() {
    return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
}

// Reduce animations on mobile for better performance
if (isMobileDevice()) {
    document.addEventListener('DOMContentLoaded', function() {
        const style = document.createElement('style');
        style.textContent = `
            * {
                animation-duration: 0.3s !important;
                transition-duration: 0.3s !important;
            }
            .logo-icon {
                animation: none !important;
            }
        `;
        document.head.appendChild(style);
    });
}

// Add keyboard shortcuts easter egg
document.addEventListener('keydown', function(e) {
    // Konami code: ↑ ↑ ↓ ↓ ← → ← → B A
    const konamiCode = [
        'ArrowUp', 'ArrowUp', 'ArrowDown', 'ArrowDown',
        'ArrowLeft', 'ArrowRight', 'ArrowLeft', 'ArrowRight',
        'KeyB', 'KeyA'
    ];
    
    if (!window.konamiProgress) {
        window.konamiProgress = 0;
    }
    
    if (e.code === konamiCode[window.konamiProgress]) {
        window.konamiProgress++;
        
        if (window.konamiProgress === konamiCode.length) {
            // Easter egg activated!
            document.body.style.filter = 'hue-rotate(180deg)';
            setTimeout(() => {
                document.body.style.filter = '';
            }, 3000);
            
            window.konamiProgress = 0;
        }
    } else {
        window.konamiProgress = 0;
    }
});