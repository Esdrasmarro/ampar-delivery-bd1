var CENTRO_GUATEMALA = [14.6150, -90.5200];

function crearMapa(idElemento, centro, zoom) {
    var mapa = L.map(idElemento).setView(centro || CENTRO_GUATEMALA, zoom || 13);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '&copy; OpenStreetMap'
    }).addTo(mapa);
    return mapa;
}

function punto(mapa, lat, lon, color, texto) {
    if (lat === null || lon === null || lat === undefined || lon === undefined) return null;
    var m = L.circleMarker([lat, lon], {radius: 9, color: '#fff', weight: 2, fillColor: color, fillOpacity: 1}).addTo(mapa);
    if (texto) m.bindTooltip(texto, {permanent: false});
    return m;
}

function mapaSelector(idElemento, idLatitud, idLongitud) {
    var campoLat = document.getElementById(idLatitud);
    var campoLon = document.getElementById(idLongitud);
    var lat = parseFloat(campoLat.value);
    var lon = parseFloat(campoLon.value);
    var tiene = !isNaN(lat) && !isNaN(lon);
    var mapa = crearMapa(idElemento, tiene ? [lat, lon] : CENTRO_GUATEMALA, tiene ? 15 : 12);
    var marcador = tiene ? L.marker([lat, lon]).addTo(mapa) : null;

    mapa.on('click', function (e) {
        campoLat.value = e.latlng.lat.toFixed(6);
        campoLon.value = e.latlng.lng.toFixed(6);
        if (marcador) {
            marcador.setLatLng(e.latlng);
        } else {
            marcador = L.marker(e.latlng).addTo(mapa);
        }
    });
    return mapa;
}
