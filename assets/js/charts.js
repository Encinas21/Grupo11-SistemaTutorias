function dibujarGraficoBarras(canvas, datos) {
    if (!canvas || !Array.isArray(datos)) return;
    const rect = canvas.getBoundingClientRect();
    const dpr = window.devicePixelRatio || 1;
    const W = Math.max(520, Math.round(rect.width || 700));
    const many = datos.length > 8;
    const H = many ? Math.max(360, datos.length * 34 + 55) : 300;
    canvas.width = W * dpr;
    canvas.height = H * dpr;
    canvas.style.height = H + 'px';
    const ctx = canvas.getContext('2d');
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    ctx.clearRect(0, 0, W, H);

    const max = Math.max(100, ...datos.map(d => Number(d.valor) || 0));
    ctx.font = '12px Arial';
    ctx.lineWidth = 1;

    if (many) {
        // Con muchos cursos usamos barras horizontales para que los nombres
        // y promedios no queden amontonados en la parte inferior.
        const left = 155, right = 55, top = 18, row = 30, barH = 17;
        const usable = W - left - right;
        datos.forEach((d, i) => {
            const y = top + i * row;
            const value = Number(d.valor) || 0;
            const barW = usable * (value / max);
            ctx.fillStyle = '#49626b';
            ctx.textAlign = 'right';
            ctx.fillText(String(d.etiqueta).slice(0, 20), left - 10, y + 13);
            ctx.fillStyle = '#e5f1f5';
            ctx.fillRect(left, y, usable, barH);
            ctx.fillStyle = '#018abd';
            ctx.fillRect(left, y, Math.max(2, barW), barH);
            ctx.fillStyle = '#49626b';
            ctx.textAlign = 'left';
            ctx.font = 'bold 12px Arial';
            ctx.fillText(value.toFixed(1), left + usable + 10, y + 13);
            ctx.font = '12px Arial';
        });
        ctx.textAlign = 'start';
        return;
    }

    const pad = 42;
    const chartH = H - pad * 2;
    ctx.strokeStyle = '#d9e7ed';
    ctx.fillStyle = '#5f747c';
    for (let i = 0; i <= 4; i++) {
        const y = H - pad - chartH * i / 4;
        ctx.beginPath();
        ctx.moveTo(pad, y);
        ctx.lineTo(W - 15, y);
        ctx.stroke();
        ctx.fillText(Math.round(max * i / 4), 8, y + 4);
    }
    const gap = (W - pad - 20) / Math.max(datos.length, 1);
    const bw = Math.max(18, gap * .55);
    datos.forEach((d, i) => {
        const value = Number(d.valor) || 0;
        const bh = chartH * (value / max);
        const x = pad + i * gap + gap / 2 - bw / 2;
        const y = H - pad - bh;
        ctx.fillStyle = '#018abd';
        ctx.beginPath();
        ctx.roundRect(x, y, bw, bh, 8);
        ctx.fill();
        ctx.fillStyle = '#49626b';
        ctx.textAlign = 'center';
        ctx.fillText(String(d.etiqueta).slice(0, 10), x + bw / 2, H - 12);
        ctx.fillText(value.toFixed(1), x + bw / 2, y - 7);
    });
    ctx.textAlign = 'start';
}
