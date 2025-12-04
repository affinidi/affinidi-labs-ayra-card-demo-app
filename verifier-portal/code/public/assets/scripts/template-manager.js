/**
 * Simple Template Manager for Dynamic HTML Views
 * Ultra-lightweight solution for managing templates
 */
class SimpleTemplateManager {
    constructor() {
        this.templates = new Map();
        this.loadTemplates();
    }

    /**
     * Load all script templates from the DOM and KioskTemplates
     */
    loadTemplates() {
        // First, load templates from KioskTemplates object if available
        if (typeof window.KioskTemplates !== 'undefined') {
            Object.keys(window.KioskTemplates).forEach(templateId => {
                this.templates.set(templateId, window.KioskTemplates[templateId].trim());
            });
        }
        
        // Then, load any remaining templates from DOM (for backward compatibility)
        const templateScripts = document.querySelectorAll('script[type="text/template"], script[id*="kiosk-"], script[id*="template-"]');
        templateScripts.forEach(script => {
            if (script.id && !script.type) {
                // For backward compatibility with scripts without type="text/template"
                if (!this.templates.has(script.id)) {
                    this.templates.set(script.id, script.innerHTML.trim());
                }
            } else if (script.id && script.type === 'text/template') {
                if (!this.templates.has(script.id)) {
                    this.templates.set(script.id, script.innerHTML.trim());
                }
            }
        });
        // console.log('Loaded templates:', Array.from(this.templates.keys()));
    }

    /**
     * Render a template to a target element
     * @param {string} templateId - ID of the template
     * @param {string|HTMLElement} target - Target element or selector
     * @param {Object} data - Data to replace placeholders
     */
    render(templateId, target, data = {}) {
        let template = this.templates.get(templateId);
        
        // If template not found, try to reload templates (DOM might have changed)
        if (!template) {
            this.loadTemplates();
            template = this.templates.get(templateId);
        }
        
        if (!template) {
            console.error(`Template '${templateId}' not found. Available templates:`, Array.from(this.templates.keys()));
            return false;
        }

        const targetElement = typeof target === 'string' 
            ? document.querySelector(target) 
            : target;
        
        if (!targetElement) {
            console.error(`Target element '${target}' not found`);
            return false;
        }

        // Simple placeholder replacement
        let html = template;
        Object.keys(data).forEach(key => {
            const placeholder = new RegExp(`{{${key}}}`, 'g');
            html = html.replace(placeholder, data[key]);
        });

        targetElement.innerHTML = html;
        return true;
    }

    /**
     * Get template HTML without rendering
     * @param {string} templateId 
     * @returns {string}
     */
    getTemplate(templateId) {
        return this.templates.get(templateId) || '';
    }

    /**
     * Register a new template programmatically
     * @param {string} id 
     * @param {string} html 
     */
    register(id, html) {
        this.templates.set(id, html);
    }

    /**
     * Show/hide elements with smooth transitions
     * @param {string|HTMLElement} element 
     * @param {boolean} show 
     */
    toggle(element, show = true) {
        const el = typeof element === 'string' 
            ? document.querySelector(element) 
            : element;
        
        if (!el) return;

        if (show) {
            el.style.display = 'block';
            el.style.opacity = '0';
            setTimeout(() => {
                el.style.transition = 'opacity 0.3s ease';
                el.style.opacity = '1';
            }, 10);
        } else {
            el.style.transition = 'opacity 0.3s ease';
            el.style.opacity = '0';
            setTimeout(() => {
                el.style.display = 'none';
            }, 300);
        }
    }

    /**
     * Animate between two templates
     * @param {string} targetSelector 
     * @param {string} newTemplateId 
     * @param {Object} data 
     * @param {number} duration 
     */
    async animateTransition(targetSelector, newTemplateId, data = {}, duration = 300) {
        const target = document.querySelector(targetSelector);
        if (!target) return;

        // Fade out
        target.style.transition = `opacity ${duration}ms ease`;
        target.style.opacity = '0';

        // Wait for fade out
        await new Promise(resolve => setTimeout(resolve, duration));

        // Change content
        this.render(newTemplateId, target, data);

        // Fade in
        target.style.opacity = '1';
    }
}

// Create global instance
window.templateManager = new SimpleTemplateManager();