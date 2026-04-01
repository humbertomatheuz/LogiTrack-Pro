package com.logitrack.util;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

/**
 * Utilitário para gerar hashes BCrypt de senhas
 * Execute este programa para gerar o hash de uma nova senha
 * 
 * Exemplo de uso no terminal:
 * java -cp target/classes com.logitrack.util.PasswordHashGenerator "minhasenha123"
 */
public class PasswordHashGenerator {

    public static void main(String[] args) {
        if (args.length == 0) {
            System.out.println("======================== PASSWORD HASH GENERATOR ========================");
            System.out.println("Uso: java -cp target/classes com.logitrack.util.PasswordHashGenerator \"SuaSenha\"");
            System.out.println();
            System.out.println("Exemplo:");
            System.out.println("  java -cp target/classes com.logitrack.util.PasswordHashGenerator \"admin123\"");
            System.out.println();
            System.out.println("Saída: Hash BCrypt da senha para usar no banco de dados");
            System.out.println("=========================================================================");
            System.exit(1);
        }

        String password = args[0];
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        String hashedPassword = encoder.encode(password);

        System.out.println("Senha original: " + password);
        System.out.println("Hash BCrypt  : " + hashedPassword);
        System.out.println();
        System.out.println("SQL para inserir novo usuário:");
        System.out.println("INSERT INTO usuarios (nome, matricula, login, senha, perfil)");
        System.out.println("VALUES ('Seu Nome', 'SUAM001', 'seu_login', '" + hashedPassword + "', 'OPERADOR');");
    }
}
