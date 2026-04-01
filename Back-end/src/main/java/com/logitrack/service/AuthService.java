package com.logitrack.service;

import com.logitrack.dto.LoginRequest;
import com.logitrack.dto.LoginResponse;
import com.logitrack.exception.InvalidCredentialsException;
import com.logitrack.model.Usuario;
import com.logitrack.repository.UsuarioRepository;
import com.logitrack.security.JwtTokenProvider;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
public class AuthService {

    private static final Logger logger = LoggerFactory.getLogger(AuthService.class);

    private final UsuarioRepository usuarioRepository;
    private final JwtTokenProvider jwtTokenProvider;
    private final PasswordEncoder passwordEncoder;

    public AuthService(UsuarioRepository usuarioRepository, JwtTokenProvider jwtTokenProvider, PasswordEncoder passwordEncoder) {
        this.usuarioRepository = usuarioRepository;
        this.jwtTokenProvider = jwtTokenProvider;
        this.passwordEncoder = passwordEncoder;
    }

    public LoginResponse login(LoginRequest request) {
        logger.info("Tentativa de login com usuário: {}", request.getLogin());
        
        Usuario usuario = usuarioRepository.findByLogin(request.getLogin())
                .orElseThrow(() -> {
                    logger.warn("Usuário não encontrado: {}", request.getLogin());
                    return new InvalidCredentialsException("Login ou senha inválidos");
                });

        logger.info("Usuário encontrado. Hash armazenado: {}", usuario.getSenha());
        
        boolean senhaValida = passwordEncoder.matches(request.getSenha(), usuario.getSenha());
        logger.info("Validação de senha: {}", senhaValida);
        
        if (!senhaValida) {
            logger.warn("Senha inválida para usuário: {}", request.getLogin());
            throw new InvalidCredentialsException("Login ou senha inválidos");
        }

        String token = jwtTokenProvider.generateToken(usuario.getLogin());

        return new LoginResponse(token, usuario.getNome(), usuario.getPerfil());
    }
}
