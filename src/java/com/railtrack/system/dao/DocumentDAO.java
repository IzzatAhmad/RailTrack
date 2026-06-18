package com.railtrack.system.dao;

import com.railtrack.system.model.DocumentType;
import com.railtrack.system.model.StudentDocument;
import com.railtrack.system.util.DBConnection;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class DocumentDAO {

    // ── DocumentType Mapping & Queries ────────────────────────────────────────

    private DocumentType mapType(ResultSet rs) throws SQLException {
        DocumentType type = new DocumentType();
        type.setId(rs.getInt("id"));
        type.setName(rs.getString("name"));
        type.setKeyCode(rs.getString("key_code"));
        type.setDescription(rs.getString("description"));
        Timestamp c = rs.getTimestamp("created_at");
        if (c != null) {
            type.setCreatedAt(c.toLocalDateTime());
        }
        return type;
    }

    public List<DocumentType> findAllDocumentTypes() throws SQLException {
        String sql = "SELECT * FROM document_types ORDER BY id ASC";
        List<DocumentType> list = new ArrayList<>();
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapType(rs));
            }
        }
        return list;
    }

    public DocumentType findDocumentTypeById(int id) throws SQLException {
        String sql = "SELECT * FROM document_types WHERE id = ?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapType(rs);
                }
            }
        }
        return null;
    }

    public DocumentType findDocumentTypeByKeyCode(String keyCode) throws SQLException {
        String sql = "SELECT * FROM document_types WHERE key_code = ?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, keyCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapType(rs);
                }
            }
        }
        return null;
    }

    public void saveDocumentType(DocumentType type) throws SQLException {
        try (Connection c = DBConnection.get()) {
            if (type.getId() == 0) {
                String sql = "INSERT INTO document_types (name, key_code, description) VALUES (?, ?, ?)";
                try (PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, type.getName());
                    ps.setString(2, type.getKeyCode());
                    ps.setString(3, type.getDescription());
                    ps.executeUpdate();
                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        if (keys.next()) {
                            type.setId(keys.getInt(1));
                        }
                    }
                }
            } else {
                String sql = "UPDATE document_types SET name = ?, key_code = ?, description = ? WHERE id = ?";
                try (PreparedStatement ps = c.prepareStatement(sql)) {
                    ps.setString(1, type.getName());
                    ps.setString(2, type.getKeyCode());
                    ps.setString(3, type.getDescription());
                    ps.setInt(4, type.getId());
                    ps.executeUpdate();
                }
            }
        }
    }

    public void deleteDocumentType(int id) throws SQLException {
        String sql = "DELETE FROM document_types WHERE id = ?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    // ── StudentDocument Mapping (NO file_data — only metadata) ────────────────

    private StudentDocument mapDoc(ResultSet rs) throws SQLException {
        StudentDocument doc = new StudentDocument();
        doc.setId(rs.getInt("id"));
        doc.setStudentId(rs.getInt("student_id"));
        doc.setDocumentTypeId(rs.getInt("document_type_id"));
        doc.setFileName(rs.getString("file_name"));
        doc.setContentType(rs.getString("content_type"));
        doc.setFileSize(rs.getInt("file_size"));
        Timestamp u = rs.getTimestamp("uploaded_at");
        if (u != null) {
            doc.setUploadedAt(u.toLocalDateTime());
        }

        // Optional joined columns
        try { doc.setStudentName(rs.getString("student_name")); }    catch (SQLException ignored) {}
        try { doc.setProjectTitle(rs.getString("project_title")); }  catch (SQLException ignored) {}
        try { doc.setDocumentTypeName(rs.getString("document_type_name")); } catch (SQLException ignored) {}

        return doc;
    }

    // ── StudentDocument Queries ───────────────────────────────────────────────

    public List<StudentDocument> findDocumentsByStudent(int studentId) throws SQLException {
        String sql = "SELECT sd.id, sd.student_id, sd.document_type_id, sd.file_name, " +
                     "sd.content_type, sd.file_size, sd.uploaded_at, " +
                     "dt.name AS document_type_name " +
                     "FROM student_documents sd " +
                     "JOIN document_types dt ON sd.document_type_id = dt.id " +
                     "WHERE sd.student_id = ? ORDER BY dt.id ASC";
        List<StudentDocument> list = new ArrayList<>();
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapDoc(rs));
                }
            }
        }
        return list;
    }

    public StudentDocument findDocumentByStudentAndType(int studentId, int typeId) throws SQLException {
        String sql = "SELECT sd.id, sd.student_id, sd.document_type_id, sd.file_name, " +
                     "sd.content_type, sd.file_size, sd.uploaded_at, " +
                     "dt.name AS document_type_name " +
                     "FROM student_documents sd " +
                     "JOIN document_types dt ON sd.document_type_id = dt.id " +
                     "WHERE sd.student_id = ? AND sd.document_type_id = ?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            ps.setInt(2, typeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapDoc(rs);
                }
            }
        }
        return null;
    }

    public StudentDocument findStudentDocumentById(int id) throws SQLException {
        String sql = "SELECT sd.id, sd.student_id, sd.document_type_id, sd.file_name, " +
                     "sd.content_type, sd.file_size, sd.uploaded_at, " +
                     "dt.name AS document_type_name, u.full_name AS student_name " +
                     "FROM student_documents sd " +
                     "JOIN document_types dt ON sd.document_type_id = dt.id " +
                     "JOIN users u ON sd.student_id = u.id " +
                     "WHERE sd.id = ?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapDoc(rs);
                }
            }
        }
        return null;
    }

    public List<StudentDocument> findAllStudentDocuments() throws SQLException {
        String sql = "SELECT sd.id, sd.student_id, sd.document_type_id, sd.file_name, " +
                     "sd.content_type, sd.file_size, sd.uploaded_at, " +
                     "dt.name AS document_type_name, u.full_name AS student_name, p.title AS project_title " +
                     "FROM student_documents sd " +
                     "JOIN document_types dt ON sd.document_type_id = dt.id " +
                     "JOIN users u ON sd.student_id = u.id " +
                     "LEFT JOIN projects p ON u.id = p.student_id " +
                     "ORDER BY sd.uploaded_at DESC";
        List<StudentDocument> list = new ArrayList<>();
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapDoc(rs));
            }
        }
        return list;
    }

    // ── Fetch raw binary data (called only by FileDownloadServlet) ────────────

    /**
     * Returns the raw BLOB bytes for a document. Returns null if not found.
     */
    public byte[] getDocumentData(int id) throws SQLException {
        String sql = "SELECT file_data FROM student_documents WHERE id = ?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getBytes("file_data");
                }
            }
        }
        return null;
    }

    // ── Save / Delete ─────────────────────────────────────────────────────────

    /**
     * Insert or replace a student document (keyed by student_id + document_type_id).
     * @param doc  metadata (fileName, contentType, fileSize, studentId, documentTypeId)
     * @param data raw file bytes to store in the BLOB column
     */
    public void saveStudentDocument(StudentDocument doc, byte[] data) throws SQLException {
        String sql = "INSERT INTO student_documents " +
                     "(student_id, document_type_id, file_name, content_type, file_size, file_data) " +
                     "VALUES (?, ?, ?, ?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE " +
                     "file_name = VALUES(file_name), content_type = VALUES(content_type), " +
                     "file_size = VALUES(file_size), file_data = VALUES(file_data)";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, doc.getStudentId());
            ps.setInt(2, doc.getDocumentTypeId());
            ps.setString(3, doc.getFileName());
            ps.setString(4, doc.getContentType());
            ps.setInt(5, doc.getFileSize());
            ps.setBytes(6, data);
            ps.executeUpdate();
        }
    }

    public void deleteStudentDocument(int studentId, int typeId) throws SQLException {
        String sql = "DELETE FROM student_documents WHERE student_id = ? AND document_type_id = ?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            ps.setInt(2, typeId);
            ps.executeUpdate();
        }
    }

    public void deleteStudentDocumentById(int id) throws SQLException {
        String sql = "DELETE FROM student_documents WHERE id = ?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }
}
