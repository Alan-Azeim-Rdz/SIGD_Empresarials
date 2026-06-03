// Please see documentation at https://learn.microsoft.com/aspnet/core/client-side/bundling-and-minification
// for details on configuring this project to bundle and minify static web assets.

// ── Lógica para el Selector de Tema Dinámico (Claro/Oscuro) ──
document.addEventListener('DOMContentLoaded', () => {
    const themeToggleBtn = document.getElementById('theme-toggle');
    if (themeToggleBtn) {
        const lightIcon = document.getElementById('theme-toggle-light-icon');
        const darkIcon = document.getElementById('theme-toggle-dark-icon');
        
        // Función para actualizar la visibilidad de los íconos de tema
        const updateThemeIcons = () => {
            const isDark = document.documentElement.getAttribute('data-theme') === 'dark';
            if (isDark) {
                // Si está en modo oscuro, muestra el sol (para alternar a claro)
                lightIcon.classList.remove('d-none');
                darkIcon.classList.add('d-none');
            } else {
                // Si está en modo claro, muestra la luna (para alternar a oscuro)
                lightIcon.classList.add('d-none');
                darkIcon.classList.remove('d-none');
            }
        };
        
        // Inicializar los íconos del botón según el tema activo
        updateThemeIcons();
        
        // Listener de clic para alternar el tema
        themeToggleBtn.addEventListener('click', () => {
            const currentTheme = document.documentElement.getAttribute('data-theme');
            const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
            
            document.documentElement.setAttribute('data-theme', newTheme);
            localStorage.setItem('theme', newTheme);
            updateThemeIcons();
        });
    }
});
