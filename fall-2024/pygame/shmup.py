import pygame
import random
import math

# Initialize pygame
pygame.init()

# Screen dimensions
SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600

# Colors
BLACK = (0, 0, 0)
WHITE = (255, 255, 255)
RED = (255, 0, 0)
YELLOW = (255, 255, 0)
BLUE = (0, 0, 255)

# Player class
class Player(pygame.sprite.Sprite):
    def __init__(self):
        super().__init__()
        self.image = pygame.Surface((50, 50))
        self.image.fill(WHITE)
        self.rect = self.image.get_rect()
        self.rect.centerx = SCREEN_WIDTH // 2
        self.rect.bottom = SCREEN_HEIGHT - 10
        self.speed_x = 0
        self.shield_time = 0  # Time in seconds the shield is charged
        self.shield_active = False
        self.shield_end_time = 0  # Time when shield will deactivate

    def update(self):
        self.speed_x = 0
        keys = pygame.key.get_pressed()
        if keys[pygame.K_LEFT]:
            self.speed_x = -5
        if keys[pygame.K_RIGHT]:
            self.speed_x = 5
        if keys[pygame.K_SPACE] and self.shield_time > 0 and not self.shield_active:
            self.activate_shield()
        self.rect.x += self.speed_x
        if self.rect.left < 0:
            self.rect.left = 0
        if self.rect.right > SCREEN_WIDTH:
            self.rect.right = SCREEN_WIDTH

        # If shield is active, check if it should deactivate
        if self.shield_active and pygame.time.get_ticks() >= self.shield_end_time:
            self.shield_active = False

    def activate_shield(self):
        self.shield_active = True
        self.shield_end_time = pygame.time.get_ticks() + self.shield_time * 1000  # Convert seconds to milliseconds
        self.shield_time = 0  # Reset shield charge

    def shoot(self):
        bullet = Bullet(self.rect.centerx, self.rect.top)
        all_sprites.add(bullet)
        bullets.add(bullet)

    def charge_shield(self, time_increment):
        self.shield_time += time_increment  # Increment shield charge

# Enemy class
class Enemy(pygame.sprite.Sprite):
    def __init__(self):
        super().__init__()
        self.image = pygame.Surface((40, 40))
        self.image.fill(RED)
        self.rect = self.image.get_rect()
        self.rect.x = random.randint(0, SCREEN_WIDTH - self.rect.width)
        self.rect.y = random.randint(-100, -40)
        self.speed_y = random.randint(1, 5)
        self.last_shot = pygame.time.get_ticks()
        self.shoot_delay = random.randint(1000, 3000)  # Delay between enemy shots

    def update(self):
        self.rect.y += self.speed_y
        if self.rect.top > SCREEN_HEIGHT:
            self.rect.x = random.randint(0, SCREEN_WIDTH - self.rect.width)
            self.rect.y = random.randint(-100, -40)
            self.speed_y = random.randint(1, 5)

        # Enemy shooting
        now = pygame.time.get_ticks()
        if now - self.last_shot > self.shoot_delay:
            self.last_shot = now
            self.shoot_bullets()

    def shoot_bullets(self):
        """Enemies shoot bullets in multiple directions."""
        num_bullets = 8  # Number of bullets per wave
        for i in range(num_bullets):
            angle = i * (360 / num_bullets)
            bullet = EnemyBullet(self.rect.centerx, self.rect.centery, angle)
            all_sprites.add(bullet)
            enemy_bullets.add(bullet)

# Bullet class for the player
class Bullet(pygame.sprite.Sprite):
    def __init__(self, x, y):
        super().__init__()
        self.image = pygame.Surface((5, 10))
        self.image.fill(WHITE)
        self.rect = self.image.get_rect()
        self.rect.centerx = x
        self.rect.bottom = y
        self.speed_y = -10

    def update(self):
        self.rect.y += self.speed_y
        if self.rect.bottom < 0:
            self.kill()

# Enemy bullet class with aura
class EnemyBullet(pygame.sprite.Sprite):
    def __init__(self, x, y, angle):
        super().__init__()
        self.image = pygame.Surface((10, 10))  # Core of the bullet
        self.image.fill(YELLOW)
        self.rect = self.image.get_rect()
        self.rect.centerx = x
        self.rect.centery = y
        self.speed = 3
        self.angle_rad = math.radians(angle)
        self.dx = math.cos(self.angle_rad) * self.speed
        self.dy = math.sin(self.angle_rad) * self.speed
        self.aura_radius = 50  # Radius of the aura around the bullet

    def update(self):
        self.rect.x += self.dx
        self.rect.y += self.dy
        if self.rect.top > SCREEN_HEIGHT or self.rect.bottom < 0 or self.rect.left < 0 or self.rect.right > SCREEN_WIDTH:
            self.kill()

        # Check if player is within the aura but not touching the core
        if player.shield_active:
            return
        distance = math.hypot(self.rect.centerx - player.rect.centerx, self.rect.centery - player.rect.centery)
        if self.aura_radius > distance > self.rect.width / 2:
            # If the player is within the aura but not touching the core
            player.charge_shield(0.05)  # Charge the shield by 0.05 seconds per frame within aura

        # Check if the player is hit by the bullet core
        if pygame.sprite.collide_rect(self, player):
            # End the game if the player is hit
            pygame.quit()
            exit()

# Initialize the game
screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
pygame.display.set_caption("Arcade Shooter with Bullet Hell and Shield Mechanic")

# Sprite groups
all_sprites = pygame.sprite.Group()
enemies = pygame.sprite.Group()
bullets = pygame.sprite.Group()
enemy_bullets = pygame.sprite.Group()

# Create player
player = Player()
all_sprites.add(player)

# Create enemies
for i in range(8):
    enemy = Enemy()
    all_sprites.add(enemy)
    enemies.add(enemy)

# Game loop
running = True
clock = pygame.time.Clock()

while running:
    clock.tick(60)

    # Handle events
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
        elif event.type == pygame.KEYDOWN:
            if event.key == pygame.K_SPACE and player.shield_time > 0 and not player.shield_active:
                player.activate_shield()
            if event.key == pygame.K_SPACE:
                player.shoot()

    # Update
    all_sprites.update()

    # Check for player bullet collisions with enemies
    hits = pygame.sprite.groupcollide(enemies, bullets, True, True)
    for hit in hits:
        enemy = Enemy()
        all_sprites.add(enemy)
        enemies.add(enemy)

    # Draw
    screen.fill(BLACK)
    
    # Draw the player's shield if active
    if player.shield_active:
        pygame.draw.circle(screen, BLUE, player.rect.center, 70, 3)

    all_sprites.draw(screen)
    pygame.display.flip()

pygame.quit()
