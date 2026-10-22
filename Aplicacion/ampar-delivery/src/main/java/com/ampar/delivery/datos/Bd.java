package com.ampar.delivery.datos;

import com.ampar.delivery.config.Sesion;
import org.springframework.jdbc.core.ConnectionCallback;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Component
public class Bd {

    private final JdbcTemplate jdbc;

    public Bd(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public List<Map<String, Object>> lista(String sql, Object... parametros) {
        return jdbc.queryForList(sql, parametros);
    }

    public Map<String, Object> uno(String sql, Object... parametros) {
        List<Map<String, Object>> filas = lista(sql, parametros);
        return filas.isEmpty() ? null : filas.get(0);
    }

    public Object valor(String sql, Object... parametros) {
        Map<String, Object> fila = uno(sql, parametros);
        return fila == null ? null : fila.values().iterator().next();
    }

    public int ejecutar(String sql, Object... parametros) {
        return jdbc.execute((ConnectionCallback<Integer>) con -> {
            identificar(con, Sesion.nombreUsuario());
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                asignar(ps, parametros);
                return ps.executeUpdate();
            }
        });
    }

    public List<Object> llamar(String procedimiento, Object[] entradas, int... tiposSalida) {
        return llamarComo(Sesion.nombreUsuario(), procedimiento, entradas, tiposSalida);
    }

    public List<Object> llamarComo(String usuario, String procedimiento, Object[] entradas, int... tiposSalida) {
        int total = entradas.length + tiposSalida.length;
        StringBuilder sql = new StringBuilder("{call " + procedimiento + "(");
        for (int i = 0; i < total; i++) {
            sql.append(i == 0 ? "?" : ", ?");
        }
        sql.append(")}");

        return jdbc.execute((ConnectionCallback<List<Object>>) con -> {
            identificar(con, usuario);
            try (CallableStatement cs = con.prepareCall(sql.toString())) {
                asignar(cs, entradas);
                for (int i = 0; i < tiposSalida.length; i++) {
                    cs.registerOutParameter(entradas.length + i + 1, tiposSalida[i]);
                }
                cs.execute();
                List<Object> salidas = new ArrayList<>();
                for (int i = 0; i < tiposSalida.length; i++) {
                    salidas.add(cs.getObject(entradas.length + i + 1));
                }
                return salidas;
            }
        });
    }

    public interface Tarea {
        void ejecutar(Connection con) throws SQLException;
    }

    public void transaccion(Tarea tarea) {
        jdbc.execute((ConnectionCallback<Void>) con -> {
            identificar(con, Sesion.nombreUsuario());
            boolean autoCommit = con.getAutoCommit();
            con.setAutoCommit(false);
            try {
                tarea.ejecutar(con);
                con.commit();
            } catch (SQLException | RuntimeException e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(autoCommit);
            }
            return null;
        });
    }

    private void identificar(Connection con, String usuario) throws SQLException {
        try (CallableStatement cs = con.prepareCall("{call DBMS_SESSION.SET_IDENTIFIER(?)}")) {
            cs.setString(1, usuario);
            cs.execute();
        }
    }

    public static void asignar(PreparedStatement ps, Object... parametros) throws SQLException {
        for (int i = 0; i < parametros.length; i++) {
            Object v = parametros[i];
            if (v == null) {
                ps.setNull(i + 1, Types.VARCHAR);
            } else {
                ps.setObject(i + 1, v);
            }
        }
    }

    public static Long aLong(Object v) {
        if (v == null) {
            return null;
        }
        if (v instanceof Number n) {
            return n.longValue();
        }
        String s = v.toString().trim();
        return s.isEmpty() ? null : Long.valueOf(s);
    }

    public static BigDecimal aDecimal(Object v) {
        if (v == null) {
            return null;
        }
        if (v instanceof BigDecimal b) {
            return b;
        }
        String s = v.toString().trim().replace(",", ".");
        return s.isEmpty() ? null : new BigDecimal(s);
    }

    public static String texto(String s) {
        if (s == null) {
            return null;
        }
        String t = s.trim();
        return t.isEmpty() ? null : t;
    }
}
