package com.ampar.delivery.reporte;

import com.lowagie.text.Document;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.FontFactory;
import com.lowagie.text.Image;
import com.lowagie.text.PageSize;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.ClientAnchor;
import org.apache.poi.ss.usermodel.Drawing;
import org.apache.poi.ss.usermodel.FillPatternType;
import org.apache.poi.ss.usermodel.IndexedColors;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Component;

import javax.imageio.ImageIO;
import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Map;

@Component
public class Exportador {

    private static final Color AZUL = new Color(18, 53, 91);
    private static final Color NARANJA = new Color(242, 140, 40);

    public byte[] excel(Tabla tabla) throws IOException {
        try (Workbook libro = new XSSFWorkbook(); ByteArrayOutputStream salida = new ByteArrayOutputStream()) {
            Sheet hoja = libro.createSheet("Reporte");

            org.apache.poi.ss.usermodel.Font negrita = libro.createFont();
            negrita.setBold(true);
            CellStyle estiloTitulo = libro.createCellStyle();
            estiloTitulo.setFont(negrita);

            CellStyle estiloEncabezado = libro.createCellStyle();
            estiloEncabezado.setFont(negrita);
            estiloEncabezado.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
            estiloEncabezado.setFillPattern(FillPatternType.SOLID_FOREGROUND);

            int r = 0;
            Row filaTitulo = hoja.createRow(r++);
            Cell celdaTitulo = filaTitulo.createCell(0);
            celdaTitulo.setCellValue("Ampar Delivery - " + tabla.getTitulo());
            celdaTitulo.setCellStyle(estiloTitulo);
            hoja.createRow(r++).createCell(0).setCellValue("Generado: " + fecha());
            r++;

            Row encabezado = hoja.createRow(r++);
            for (int c = 0; c < tabla.getColumnas().size(); c++) {
                Cell celda = encabezado.createCell(c);
                celda.setCellValue(tabla.getColumnas().get(c)[1]);
                celda.setCellStyle(estiloEncabezado);
            }

            for (Map<String, Object> fila : tabla.getFilas()) {
                Row row = hoja.createRow(r++);
                for (int c = 0; c < tabla.getColumnas().size(); c++) {
                    Object v = fila.get(tabla.getColumnas().get(c)[0]);
                    Cell celda = row.createCell(c);
                    if (v instanceof Number n) {
                        celda.setCellValue(n.doubleValue());
                    } else if (v != null) {
                        celda.setCellValue(texto(v));
                    }
                }
            }
            for (int c = 0; c < tabla.getColumnas().size(); c++) {
                hoja.autoSizeColumn(c);
            }

            if (tabla.tieneGrafico()) {
                int indice = libro.addPicture(graficoPng(tabla), Workbook.PICTURE_TYPE_PNG);
                Drawing<?> dibujo = hoja.createDrawingPatriarch();
                ClientAnchor ancla = libro.getCreationHelper().createClientAnchor();
                ancla.setCol1(tabla.getColumnas().size() + 1);
                ancla.setRow1(3);
                dibujo.createPicture(ancla, indice).resize();
            }

            libro.write(salida);
            return salida.toByteArray();
        }
    }

    public byte[] pdf(Tabla tabla) throws Exception {
        ByteArrayOutputStream salida = new ByteArrayOutputStream();
        Document documento = new Document(PageSize.A4.rotate(), 30, 30, 30, 30);
        PdfWriter.getInstance(documento, salida);
        documento.open();

        Font fuenteTitulo = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 16, new Color(18, 53, 91));
        Font fuenteNormal = FontFactory.getFont(FontFactory.HELVETICA, 9);
        Font fuenteEncabezado = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 9, Color.WHITE);

        documento.add(new Paragraph("Ampar Delivery - " + tabla.getTitulo(), fuenteTitulo));
        documento.add(new Paragraph("Generado: " + fecha(), fuenteNormal));
        if (!tabla.getDescripcion().isEmpty()) {
            documento.add(new Paragraph(tabla.getDescripcion(), fuenteNormal));
        }
        documento.add(new Paragraph(" "));

        if (tabla.tieneGrafico()) {
            Image imagen = Image.getInstance(graficoPng(tabla));
            imagen.scaleToFit(720, 300);
            imagen.setAlignment(Element.ALIGN_CENTER);
            documento.add(imagen);
            documento.add(new Paragraph(" "));
        }

        PdfPTable pdfTabla = new PdfPTable(tabla.getColumnas().size());
        pdfTabla.setWidthPercentage(100);
        for (String[] col : tabla.getColumnas()) {
            PdfPCell celda = new PdfPCell(new Phrase(col[1], fuenteEncabezado));
            celda.setBackgroundColor(AZUL);
            celda.setPadding(4);
            pdfTabla.addCell(celda);
        }
        pdfTabla.setHeaderRows(1);
        for (Map<String, Object> fila : tabla.getFilas()) {
            for (String[] col : tabla.getColumnas()) {
                Object v = fila.get(col[0]);
                PdfPCell celda = new PdfPCell(new Phrase(v == null ? "" : texto(v), fuenteNormal));
                celda.setPadding(3);
                if (v instanceof Number) {
                    celda.setHorizontalAlignment(Element.ALIGN_RIGHT);
                }
                pdfTabla.addCell(celda);
            }
        }
        documento.add(pdfTabla);
        documento.close();
        return salida.toByteArray();
    }

    public byte[] graficoPng(Tabla tabla) throws IOException {
        int n = tabla.getEtiquetas().size();
        int ancho = 900;
        int alto = 60 + n * 30;
        int izquierda = 230;
        int maxAncho = ancho - izquierda - 80;

        double maximo = 1;
        for (Number v : tabla.getValores()) {
            maximo = Math.max(maximo, v.doubleValue());
        }

        BufferedImage imagen = new BufferedImage(ancho, alto, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = imagen.createGraphics();
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        g.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON);
        g.setColor(Color.WHITE);
        g.fillRect(0, 0, ancho, alto);

        g.setColor(AZUL);
        g.setFont(new java.awt.Font("SansSerif", java.awt.Font.BOLD, 16));
        g.drawString(tabla.getTituloGrafico(), 10, 25);

        g.setFont(new java.awt.Font("SansSerif", java.awt.Font.PLAIN, 13));
        for (int i = 0; i < n; i++) {
            int y = 45 + i * 30;
            double valor = tabla.getValores().get(i).doubleValue();
            int largo = (int) (maxAncho * valor / maximo);

            String etiqueta = tabla.getEtiquetas().get(i);
            if (etiqueta.length() > 32) {
                etiqueta = etiqueta.substring(0, 31) + "…";
            }
            g.setColor(Color.DARK_GRAY);
            g.drawString(etiqueta, 10, y + 16);

            g.setColor(i == 0 ? NARANJA : AZUL);
            g.fillRect(izquierda, y, Math.max(largo, 2), 22);

            g.setColor(Color.BLACK);
            g.drawString(formatoNumero(valor), izquierda + largo + 8, y + 16);
        }
        g.setColor(Color.LIGHT_GRAY);
        g.setStroke(new BasicStroke(1));
        g.drawLine(izquierda, 40, izquierda, alto - 10);
        g.dispose();

        ByteArrayOutputStream salida = new ByteArrayOutputStream();
        ImageIO.write(imagen, "png", salida);
        return salida.toByteArray();
    }

    private String fecha() {
        return new SimpleDateFormat("dd/MM/yyyy HH:mm").format(new Date());
    }

    private String formatoNumero(double v) {
        return v == Math.rint(v) ? String.valueOf((long) v) : String.format("%.2f", v);
    }

    private String texto(Object v) {
        if (v instanceof java.sql.Timestamp t) {
            return new SimpleDateFormat("dd/MM/yyyy HH:mm").format(t);
        }
        if (v instanceof Date d) {
            return new SimpleDateFormat("dd/MM/yyyy HH:mm").format(d);
        }
        return String.valueOf(v);
    }
}
