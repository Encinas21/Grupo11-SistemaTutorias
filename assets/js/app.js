document.addEventListener('DOMContentLoaded', () => {
    initMobileMenu();
    initFormValidation();
    initSearch();
    initModals();
    initAjaxCrudModals();
    initModalFormSubmissions();
    initUserFormHints(document);
    initConfirmations();
    initTutorMateriaSelector();
    initTutoriasCalendar();
    initFilterDates();
    initReviewStars();
    autoHideAlerts();
    initSidebarScrollPersistence();
    initTemplatePreviews();
});

function initMobileMenu() {
    const toggle = document.querySelector('[data-menu-toggle]');
    const sidebar = document.querySelector('.sidebar');
    const overlay = document.querySelector('[data-sidebar-overlay]');

    if (!toggle || !sidebar) return;

    const closeMenu = () => {
        sidebar.classList.remove('open');
        overlay?.classList.remove('show');
    };

    toggle.addEventListener('click', () => {
        sidebar.classList.toggle('open');
        overlay?.classList.toggle('show');
    });

    overlay?.addEventListener('click', closeMenu);
    document.querySelectorAll('.sidebar .nav-link').forEach((link) => link.addEventListener('click', closeMenu));
}


function initSidebarScrollPersistence() {
    const sidebar = document.querySelector('.sidebar');
    if (!sidebar) return;

    const key = 'sistema_tutorias_sidebar_scroll_v2';
    const readSaved = () => {
        const raw = window.sessionStorage.getItem(key) ?? window.localStorage.getItem(key) ?? '0';
        const value = Number.parseInt(raw, 10);
        return Number.isFinite(value) && value >= 0 ? value : 0;
    };
    const save = () => {
        const value = String(Math.max(0, Math.round(sidebar.scrollTop)));
        window.sessionStorage.setItem(key, value);
        window.localStorage.setItem(key, value);
    };
    const restore = () => {
        const max = Math.max(0, sidebar.scrollHeight - sidebar.clientHeight);
        sidebar.scrollTop = Math.min(readSaved(), max);
        sidebar.classList.add('sidebar-ready');
    };

    // Evita el salto visual: la barra permanece oculta hasta que su posición
    // anterior haya sido restaurada después de renderizar el nuevo documento.
    restore();
    window.requestAnimationFrame(restore);
    window.setTimeout(restore, 40);
    window.setTimeout(restore, 140);

    sidebar.addEventListener('scroll', save, { passive: true });
    sidebar.querySelectorAll('.nav-link').forEach((link) => {
        link.addEventListener('pointerdown', save, { passive: true });
        link.addEventListener('click', save, { passive: true });
    });
    window.addEventListener('pagehide', save, { passive: true });
    window.addEventListener('beforeunload', save, { passive: true });
    window.addEventListener('pageshow', restore, { passive: true });
}

function initTemplatePreviews() {
    document.querySelectorAll('[data-template-editor]').forEach((textarea) => {
        const preview = document.querySelector(textarea.dataset.templatePreview || '');
        if (!preview) return;
        const render = () => {
            const wrapper = document.createElement('div');
            wrapper.innerHTML = textarea.value || '<p class="muted">Escribe contenido HTML para ver la vista previa.</p>';
            wrapper.querySelectorAll('script,iframe,object,embed').forEach((node) => node.remove());
            wrapper.querySelectorAll('*').forEach((node) => {
                [...node.attributes].forEach((attr) => {
                    if (/^on/i.test(attr.name)) node.removeAttribute(attr.name);
                });
            });
            preview.replaceChildren(...Array.from(wrapper.childNodes));
        };
        textarea.addEventListener('input', render);
        render();
    });
}

function initFormValidation(root = document) {
    const letrasPattern = /^\p{L}+(?: \p{L}+)*$/u;
    const telefonoPattern = /^\d{8}$/;
    const ciPattern = /^\d{7,8}$/;
    const updsEmailPattern = /^[A-Za-z0-9._%+-]+@upds\.net\.com$/i;
    const personaPattern = /^[A-ZÁÉÍÓÚÜÑ][a-záéíóúüñ]+(?: [A-ZÁÉÍÓÚÜÑ][a-záéíóúüñ]+)*$/u;

    root.querySelectorAll('form').forEach((form) => {
        form.querySelectorAll('[required], [data-only-letters]').forEach((field) => {
            const clear = () => field.setCustomValidity('');
            field.addEventListener('input', clear);
            field.addEventListener('change', clear);
        });

        form.querySelectorAll('[data-phone-bolivia]').forEach((field) => {
            field.addEventListener('input', () => { field.value = field.value.replace(/\D/g, '').slice(0, 8); });
        });

        form.querySelectorAll('[data-person-name]').forEach((field) => {
            field.addEventListener('input', () => {
                field.value = field.value.replace(/\s+/g, ' ');
            });
        });

        form.querySelectorAll('[data-ci]').forEach((field) => {
            field.addEventListener('input', () => { field.value = field.value.replace(/\D/g, '').slice(0, 8); });
        });

        form.querySelectorAll('[data-course-code]').forEach((field) => {
            field.addEventListener('input', () => { field.value = field.value.toUpperCase().replace(/[^A-Z0-9-]/g, '').slice(0, 8); });
        });

        form.querySelectorAll('[data-no-sunday]').forEach((field) => {
            field.addEventListener('change', () => {
                if (!field.value) { field.setCustomValidity(''); return; }
                const date = new Date(field.value + 'T12:00:00');
                field.setCustomValidity(date.getDay() === 0 ? 'Los domingos no se pueden programar clases ni tutorías.' : '');
            });
        });

        form.addEventListener('submit', (event) => {
            form.querySelectorAll('[required]').forEach((field) => {
                if (typeof field.value === 'string' && field.value.trim() === '') {
                    field.setCustomValidity('Este campo es obligatorio.');
                } else {
                    field.setCustomValidity('');
                }
            });

            form.querySelectorAll('[data-only-letters]').forEach((field) => {
                const value = field.value.trim();
                if (value && !letrasPattern.test(value)) {
                    field.setCustomValidity('Este campo solo admite letras.');
                }
            });

            form.querySelectorAll('[data-person-name]').forEach((field) => {
                const value = field.value.trim();
                if (value && !personaPattern.test(value)) {
                    field.setCustomValidity('Ingresa un nombre o apellido válido y comienza con mayúscula.');
                }
            });

            form.querySelectorAll('[data-upds-email]').forEach((field) => {
                const value = field.value.trim();
                if (value && !updsEmailPattern.test(value)) {
                    field.setCustomValidity('El correo debe terminar en @upds.net.com.');
                }
            });

            form.querySelectorAll('[data-phone-bolivia]').forEach((field) => {
                const value = field.value.trim();
                if (value && !telefonoPattern.test(value)) {
                    field.setCustomValidity('El teléfono debe tener exactamente 8 dígitos numéricos.');
                }
            });

            form.querySelectorAll('[data-person-name]').forEach((field) => {
            field.addEventListener('input', () => {
                field.value = field.value.replace(/\s+/g, ' ');
            });
        });

        form.querySelectorAll('[data-ci]').forEach((field) => {
                const value = field.value.trim();
                if (value && !ciPattern.test(value)) {
                    field.setCustomValidity('La Cédula de Identidad debe contener solamente 7 u 8 dígitos.');
                }
            });

            form.querySelectorAll('[data-no-sunday]').forEach((field) => {
                if (field.value) {
                    const date = new Date(field.value + 'T12:00:00');
                    if (date.getDay() === 0) field.setCustomValidity('Los domingos no se pueden programar clases ni tutorías.');
                }
            });

            const password = form.querySelector('input[name="clave"]');
            const confirmation = form.querySelector('input[name="confirmar_clave"]');
            if (password && confirmation) {
                const requiredPassword = password.hasAttribute('required');
                if (requiredPassword || password.value || confirmation.value) {
                    if (!password.value || !confirmation.value) {
                        confirmation.setCustomValidity('Confirma la contraseña.');
                    } else if (password.value !== confirmation.value) {
                        confirmation.setCustomValidity('Las contraseñas no coinciden.');
                    } else {
                        confirmation.setCustomValidity('');
                    }
                }
            }

            if (!form.checkValidity()) {
                event.preventDefault();
                form.reportValidity();
            }
        });
    });
}


function initSearch() {
    document.querySelectorAll('[data-search]').forEach((search) => {
        const selector = search.dataset.search;
        if (!selector) return;
        const table = document.querySelector(selector);
        if (!table) return;

        const rows = [...table.querySelectorAll('tbody tr')];
        search.addEventListener('input', () => {
            const term = search.value.trim().toLowerCase();
            rows.forEach((row) => {
                row.style.display = row.textContent.toLowerCase().includes(term) ? '' : 'none';
            });
        });
    });
}

function initModals() {
    document.querySelectorAll('.modal').forEach(bindModal);

    document.querySelectorAll('[data-open-modal]').forEach((trigger) => {
        trigger.addEventListener('click', (event) => {
            event.preventDefault();
            const selector = trigger.dataset.openModal || trigger.getAttribute('href');
            if (!selector) return;
            const modal = document.querySelector(selector);
            if (!modal) return;
            modal.classList.add('is-open');
            syncModalBodyLock();
            const firstField = modal.querySelector('input:not([type="hidden"]), select, textarea');
            firstField?.focus({ preventScroll: true });
        });
    });

    syncModalBodyLock();

    document.addEventListener('keydown', (event) => {
        if (event.key !== 'Escape') return;
        const modal = document.querySelector('.modal.is-open');
        if (modal) closeModal(modal);
    });
}

function syncModalBodyLock() {
    document.body.classList.toggle('modal-open', !!document.querySelector('.modal.is-open'));
}

function closeModal(modal) {
    if (!modal) return;

    if (modal.dataset.dynamic === '1') {
        modal.classList.remove('is-open');
        window.setTimeout(() => modal.remove(), 180);
    } else {
        modal.classList.remove('is-open');
    }

    syncModalBodyLock();
}

function ensureModalNotice(modal) {
    const dialog = modal?.querySelector('.modal-dialog');
    if (!dialog) return null;

    let slot = dialog.querySelector(':scope > .modal-notice-slot');
    if (!slot) {
        slot = document.createElement('div');
        slot.className = 'modal-notice-slot';
        slot.setAttribute('aria-live', 'polite');
        slot.setAttribute('aria-atomic', 'true');
        slot.setAttribute('role', 'status');
        const body = dialog.querySelector(':scope > .modal-body');
        dialog.insertBefore(slot, body || null);
    }
    return slot;
}

function setModalNotice(modal, message, type = 'error') {
    const slot = ensureModalNotice(modal);
    if (!slot) return;
    slot.replaceChildren();
    const text = String(message || '').trim();
    if (!text) {
        slot.dataset.visible = 'false';
        return;
    }
    const alertBox = document.createElement('div');
    alertBox.className = `alert ${type === 'success' ? 'alert-success' : 'alert-error'} modal-notice`;
    alertBox.setAttribute('role', type === 'success' ? 'status' : 'alert');
    alertBox.textContent = text;
    slot.appendChild(alertBox);
    slot.dataset.visible = 'true';
}

function bindModal(modal) {
    if (!modal) return;
    const legacyError = modal.querySelector('.modal-body .alert-error');
    const slot = ensureModalNotice(modal);
    if (legacyError && slot && !slot.querySelector('.modal-notice')) {
        setModalNotice(modal, legacyError.textContent.trim());
        legacyError.remove();
    }
    if (modal.dataset.modalBound === '1') return;
    modal.dataset.modalBound = '1';

    const dialog = modal.querySelector('.modal-dialog');

    modal.addEventListener('click', (event) => {
        if (event.target !== modal) return;

        if (modal.dataset.dynamic === '1') {
            closeModal(modal);
        } else if (modal.dataset.closeUrl) {
            window.location.href = modal.dataset.closeUrl;
        }
    });

    modal.querySelectorAll('[data-modal-close]').forEach((button) => {
        button.addEventListener('click', (event) => {
            event.preventDefault();
            if (modal.dataset.dynamic === '1') {
                closeModal(modal);
            } else if (modal.dataset.closeUrl) {
                window.location.href = modal.dataset.closeUrl;
            } else {
                closeModal(modal);
            }
        });
    });

    dialog?.addEventListener('click', (event) => event.stopPropagation());

    if (modal.classList.contains('is-open')) syncModalBodyLock();
}

function initAjaxCrudModals() {
    document.addEventListener('click', async (event) => {
        const link = event.target.closest('a');
        if (!link || link.target === '_blank' || link.hasAttribute('download')) return;

        const href = link.getAttribute('href');
        if (!href || href.startsWith('#') || href.startsWith('javascript:')) return;

        let url;
        try {
            url = new URL(href, window.location.href);
        } catch (_) {
            return;
        }

        if (url.origin !== window.location.origin) return;

        const accion = url.searchParams.get('accion');
        const esCrudModal = accion === 'crear' || accion === 'editar' || accion === 'ver' || (accion === 'form' && url.searchParams.get('modal') === '1');
        if (!esCrudModal) return;

        // Solo interceptamos las pantallas CRUD. Los formularios siguen usando
        // sus controladores PHP y su validación normal al guardar.
        event.preventDefault();
        await cargarModalDesdeUrl(url.toString());
    });
}

async function cargarModalDesdeUrl(url) {
    const modalActual = document.querySelector('.modal.is-open');
    if (modalActual) closeModal(modalActual);

    try {
        const response = await fetch(url, {
            credentials: 'same-origin',
            headers: { 'X-Requested-With': 'XMLHttpRequest' },
        });

        if (!response.ok) throw new Error(`HTTP ${response.status}`);

        const html = await response.text();
        const parser = new DOMParser();
        const documentRemote = parser.parseFromString(html, 'text/html');
        const modal = documentRemote.querySelector('.modal');

        if (!modal) {
            // Si el servidor no devolvió un modal, mantenemos el comportamiento
            // clásico para no romper ninguna pantalla.
            window.location.href = url;
            return;
        }

        modal.dataset.dynamic = '1';
        modal.removeAttribute('data-close-url');
        modal.classList.remove('is-open');
        document.body.appendChild(modal);
        bindModal(modal);

        requestAnimationFrame(() => {
            modal.classList.add('is-open');
            syncModalBodyLock();
            const firstField = modal.querySelector('input:not([type="hidden"]), select, textarea');
            firstField?.focus({ preventScroll: true });
        });

        // Los selectores dependientes de tutor/materia también deben funcionar
        // dentro de un modal cargado dinámicamente.
        initTutorMateriaSelector(modal);
        initFormValidation(modal);
        initUserFormHints(modal);
    } catch (error) {
        console.error('No se pudo cargar el formulario modal:', error);
        window.location.href = url;
    }
}

function initUserFormHints(root = document) {
    const forms = [];
    if (root.matches?.('[data-user-form]')) forms.push(root);
    root.querySelectorAll?.('[data-user-form]').forEach((form) => forms.push(form));

    forms.forEach((form) => {
        if (form.dataset.userHintsBound === '1') return;
        form.dataset.userHintsBound = '1';
        const role = form.querySelector('[name="id_rol"]');
        const username = form.querySelector('[name="usuario"]');
        if (!role || !username) return;

        const updatePlaceholder = () => {
            const selected = role.value;
            if (selected === '1') username.placeholder = 'admin (cuenta administradora existente)';
            else if (selected === '2') username.placeholder = form.dataset.nextDocente || 'docente51';
            else if (selected === '3') username.placeholder = form.dataset.nextEstudiante || 'estudiante1001';
            else username.placeholder = 'Selecciona primero un rol';
        };
        role.addEventListener('change', updatePlaceholder);
        updatePlaceholder();
    });
}

function initModalFormSubmissions() {
    document.addEventListener('submit', async (event) => {
        const form = event.target.closest('.modal form');
        if (event.defaultPrevented || !form || form.dataset.noAjax === '1') return;
        event.preventDefault();

        const modal = form.closest('.modal');
        // El espacio de notificación existe desde que se abre la ventana, por lo
        // que mostrar/ocultar un error no cambia el tamaño ni la posición del modal.
        setModalNotice(modal, '');
        const submitButton = form.querySelector('button[type="submit"], button:not([type])');
        const originalText = submitButton?.textContent;
        if (submitButton) {
            submitButton.disabled = true;
            submitButton.textContent = 'Guardando…';
        }

        try {
            const response = await fetch(form.action || window.location.href, {
                method: (form.method || 'POST').toUpperCase(),
                body: new FormData(form),
                credentials: 'same-origin',
                headers: { 'X-Requested-With': 'XMLHttpRequest' },
            });
            const html = await response.text();
            const parsed = new DOMParser().parseFromString(html, 'text/html');
            const returnedModal = parsed.querySelector('.modal');
            const newDialog = returnedModal?.querySelector('.modal-dialog');
            const currentDialog = modal?.querySelector('.modal-dialog');

            if (newDialog && currentDialog) {
                // Un error de validación nunca reemplaza el formulario actual:
                // hacerlo reiniciaba el scroll interno y daba la impresión de
                // que la ventana se movía. Solo actualizamos la franja reservada.
                const returnedError = newDialog.querySelector('.modal-body .alert-error, .modal-notice-slot .alert-error');
                const message = returnedError?.textContent?.trim() || 'No se pudo guardar. Revisa los datos ingresados e inténtalo nuevamente.';
                setModalNotice(modal, message, 'error');
                modal.classList.add('is-open');
                syncModalBodyLock();
            } else {
                // En caso de éxito, el controlador redirige a la lista.
                window.location.assign(response.url || window.location.href);
            }
        } catch (error) {
            console.error('No se pudo enviar el formulario modal:', error);
            setModalNotice(modal, 'No se pudo conectar con el servidor. Revisa tu conexión e inténtalo nuevamente.', 'error');
        } finally {
            if (submitButton?.isConnected) {
                submitButton.disabled = false;
                submitButton.textContent = originalText || 'Guardar';
            }
        }
    });
}

function initConfirmations() {
    document.querySelectorAll('[data-confirm]').forEach((element) => {
        element.addEventListener('click', async (event) => {
            const message = element.dataset.confirm || '¿Confirmar acción?';
            if (typeof window.Swal === 'undefined') {
                if (!window.confirm(message)) event.preventDefault();
                return;
            }

            event.preventDefault();
            const result = await window.Swal.fire({
                title: 'Confirmar acción',
                text: message,
                icon: 'warning',
                showCancelButton: true,
                confirmButtonText: 'Sí, continuar',
                cancelButtonText: 'Cancelar',
                confirmButtonColor: '#018abd',
                reverseButtons: true,
            });

            if (!result.isConfirmed) return;
            const form = element.closest('form');
            if (form) {
                form.submit();
            } else if (element.href) {
                window.location.href = element.href;
            }
        });
    });
}

function initTutorMateriaSelector(root = document) {
    const tutorSelector = root.querySelector('[data-tutor-selector]');
    const materiaSelector = root.querySelector('[data-materia-selector]');
    const disponibilidadPanel = root.querySelector('[data-disponibilidad-panel]');
    const disponibilidadDataEl = root.querySelector('#disponibilidad-data');

    let disponibilidad = {};
    if (disponibilidadDataEl) {
        try {
            disponibilidad = JSON.parse(disponibilidadDataEl.textContent || '{}');
        } catch (e) {
            disponibilidad = {};
        }
    }

    const pintarDisponibilidad = (idTutor) => {
        if (!disponibilidadPanel) {
            return;
        }

        const slots = disponibilidad[idTutor] || disponibilidad[String(idTutor)] || [];

        if (!idTutor) {
            disponibilidadPanel.textContent = 'Selecciona un tutor para ver sus horarios disponibles.';
            return;
        }

        if (slots.length === 0) {
            disponibilidadPanel.textContent = 'Este tutor todavía no registró horarios de disponibilidad.';
            return;
        }

        disponibilidadPanel.innerHTML = 'Disponibilidad del tutor: ' + slots.map((slot) => {
            const inicio = (slot.hora_inicio || '').slice(0, 5);
            const fin = (slot.hora_fin || '').slice(0, 5);
            return `<span class="badge badge-light">${slot.dia_semana} ${inicio}–${fin}</span>`;
        }).join(' ');
    };

    if (tutorSelector) {
        tutorSelector.addEventListener('change', () => {
            pintarDisponibilidad(tutorSelector.value);
        });
    }
    if (!tutorSelector || !materiaSelector) return;

    const updateMaterias = () => {
        const tutorId = tutorSelector.value;
        let selectedVisible = false;
        [...materiaSelector.options].forEach((option) => {
            if (!option.dataset.tutor) { option.hidden = false; return; }
            const visible = option.dataset.tutor === tutorId;
            option.hidden = !visible;
            if (visible && option.selected) selectedVisible = true;
        });
        if (!selectedVisible && tutorId) materiaSelector.value = '';
    };

    tutorSelector.addEventListener('change', updateMaterias);
    updateMaterias();
}

function initTutoriasCalendar() {
    const calendarElement = document.getElementById('calendar');
    if (!calendarElement || typeof FullCalendar === 'undefined') return;

    const canCreate = calendarElement.dataset.canCreate === '1';
    const endpoint = calendarElement.dataset.calendarUrl;
    const calendar = new FullCalendar.Calendar(calendarElement, {
        locale: 'es', firstDay: 1, height: 760, contentHeight: 700, dayMinHeight: 105, expandRows: true, dayMaxEvents: 3,
        nowIndicator: true, editable: false, selectable: false, eventDisplay: 'block', eventOrder: 'start,title',
        headerToolbar: { left: 'prev,next today', center: 'title', right: 'dayGridMonth,timeGridWeek,listWeek' },
        buttonText: { today: 'Hoy', month: 'Mes', week: 'Semana', list: 'Lista' },
        events: { url: endpoint, method: 'GET', failure: () => window.alert('No se pudo cargar el calendario de tutorías.') },
        eventClick: (info) => { info.jsEvent.preventDefault(); if (info.event.url) window.location.href = info.event.url; },
        eventDidMount: (info) => {
            const props = info.event.extendedProps;
            info.el.title = [props.materia || info.event.title, props.tutor ? `Tutor: ${props.tutor}` : '', props.estudiante ? `Estudiante: ${props.estudiante}` : '', props.aula ? `Aula: ${props.aula}` : '', props.horario ? `Horario: ${props.horario}` : '', props.estado ? `Estado: ${props.estado}` : ''].filter(Boolean).join('\n');
        },
        dateClick: (info) => {
            if (!canCreate) return;
            const partes = info.dateStr.split('T');
            const params = new URLSearchParams({ accion: 'crear', fecha: partes[0] });
            window.location.href = `/controllers/tutorias.php?${params.toString()}`;
        },
    });
    calendar.render();
}

function initFilterDates() {
    const desde = document.getElementById('fecha_desde');
    const hasta = document.getElementById('fecha_hasta');
    if (!desde || !hasta) return;
    const updateRange = () => { hasta.min = desde.value || ''; };
    desde.addEventListener('change', updateRange);
    updateRange();
}

function initReviewStars() {
    const container = document.querySelector('[data-star-input]');
    if (!container) return;
    container.addEventListener('change', () => container.classList.add('selected'));
}

function autoHideAlerts() {
    document.querySelectorAll('.alert').forEach((alert) => {
        if (typeof window.Swal !== 'undefined' && alert.dataset.toast === '1') {
            window.Swal.fire({
                toast: true,
                position: 'top-end',
                icon: alert.classList.contains('alert-success') ? 'success' : 'error',
                title: alert.textContent.trim(),
                showConfirmButton: false,
                timer: 3500,
                timerProgressBar: true,
            });
            alert.remove();
            return;
        }
        window.setTimeout(() => {
            alert.style.opacity = '0';
            alert.style.transform = 'translateY(-4px)';
            window.setTimeout(() => alert.remove(), 250);
        }, 6000);
    });
}