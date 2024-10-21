import pygame
import random

# Initialize pygame
pygame.init()

# Screen dimensions
WIDTH, HEIGHT = 800, 400
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("Parkour Runner")

# Colors
WHITE = (255, 255, 255)
BLACK = (0, 0, 0)
RED = (255, 0, 0)

# Game variables
FPS = 60
GRAVITY = 1
JUMP_HEIGHT = 20
GROUND_LEVEL = HEIGHT - 50


# Player class
class Player(pygame.sprite.Sprite):
    def __init__(self):
        super().__init__()
        self.image = pygame.Surface((50, 50))
        self.image.fill(BLACK)
        self.rect = self.image.get_rect()
        self.rect.x = 100
        self.rect.y = GROUND_LEVEL
        self.velocity_y = 0
        self.is_jumping = False

    def update(self):
        keys = pygame.key.get_pressed()

        if keys[pygame.K_SPACE] and not self.is_jumping:
            self.is_jumping = True
            self.velocity_y = -JUMP_HEIGHT

        self.velocity_y += GRAVITY
        self.rect.y += self.velocity_y

        # Player cannot go below ground
        if self.rect.y >= GROUND_LEVEL:
            self.rect.y = GROUND_LEVEL
            self.is_jumping = False


# Obstacle class
class Obstacle(pygame.sprite.Sprite):
    def __init__(self):
        super().__init__()
        self.image = pygame.Surface((50, 50))
        self.image.fill(RED)
        self.rect = self.image.get_rect()
        self.rect.x = WIDTH
        self.rect.y = GROUND_LEVEL

    def update(self):
        self.rect.x -= 10  # Speed of obstacles
        if self.rect.x < -50:
            self.kill()  # Remove the obstacle if it's off-screen


# Game loop
def game():
    clock = pygame.time.Clock()
    score = 0

    # Create sprite groups
    player = Player()
    all_sprites = pygame.sprite.Group()
    all_sprites.add(player)

    obstacles = pygame.sprite.Group()

    running = True
    obstacle_timer = 0

    while running:
        clock.tick(FPS)

        # Handle events
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False

        # Update player
        all_sprites.update()

        # Spawn obstacles
        obstacle_timer += 1
        if obstacle_timer > 60:  # Spawn an obstacle every 60 frames
            obstacle_timer = 0
            obstacle = Obstacle()
            all_sprites.add(obstacle)
            obstacles.add(obstacle)

        # Check for collisions
        if pygame.sprite.spritecollideany(player, obstacles):
            running = False  # Game over if player hits obstacle

        # Increase score
        score += 1

        # Drawing
        screen.fill(WHITE)
        all_sprites.draw(screen)

        # Draw score
        font = pygame.font.Font(None, 36)
        score_text = font.render(f"Score: {score}", True, BLACK)
        screen.blit(score_text, (10, 10))

        pygame.display.flip()

    # Quit pygame
    pygame.quit()


# Run the game
game()
