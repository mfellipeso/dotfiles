# Restaurar snapshot Btrfs (Snapper)

Procedimentos para reverter o sistema a uma snapshot do Snapper neste ThinkPad.

---

## Método 1 — Sistema ainda boota: `snapper rollback` (recomendado)

Use quando o GRUB abre e o submenu **"Arch Linux snapshots"** consegue bootar
a snapshot.

1. Reinicie e, no GRUB, entre em **Arch Linux snapshots** → escolha a snapshot
   → boote nela (sobe **read-only**, é só pra testar).
2. Dentro da snapshot bootada:

   ```bash
   sudo snapper rollback
   ```

   Isso cria um snapshot do estado atual (registro), gera um novo subvolume
   read-write a partir da snapshot bootada e o define como default.

3. Reinicie normalmente:

   ```bash
   reboot
   ```

Alternativa GUI: **Btrfs Assistant** → aba _Snapper_ → selecionar snapshot →
**Restore**.

---

## Método 2 — Sistema imbootável: restauração manual via live USB

Use quando nada boota. Rode a partir de um **live USB** do Arch/CachyOS.

```bash
# 1. (Opcional) liste as snapshots, se conseguir chroot/montar antes
snapper -c root list

# 2. Monte o TOPO do btrfs (subvolid=5), NÃO o mount simples.
#    O default é o @ (subvolid 256); montar o topo expõe @, @home, etc.
mount -o subvolid=5 /dev/nvme0n1p2 /mnt

# 3. Renomeie o subvolume raiz quebrado
mv /mnt/@ /mnt/@.old

# 4. Crie um novo @ read-write a partir da snapshot (<ID> = número da lista)
btrfs subvolume snapshot /mnt/@.old/.snapshots/<ID>/snapshot /mnt/@

# 5. Preserve o histórico de snapshots (vivem aninhadas dentro do @)
rmdir /mnt/@/.snapshots          # remove a pasta residual vazia
mv /mnt/@.old/.snapshots /mnt/@/ # traz as snapshots antigas

# 6. Reinicie
umount /mnt && reboot
```

Depois de confirmar que o sistema voltou ok, apague o subvolume antigo:

```bash
mount -o subvolid=5 /dev/nvme0n1p2 /mnt
btrfs subvolume delete /mnt/@.old
umount /mnt
```

### Cuidados do método 2

- **`mount -o subvolid=5`** é obrigatório. `mount /dev/nvme0n1p2 /mnt` simples
  cairia _dentro_ do `@` e não existiria `/mnt/@`.
- Confirme o device com `lsblk -f` antes (aqui é `/dev/nvme0n1p2`).
- O passo 5 é o que evita perder o histórico de snapshots.

---

## Qual método usar

| Situação                          | Método                        |
| --------------------------------- | ----------------------------- |
| GRUB abre e a snapshot boota      | Método 1 (`snapper rollback`) |
| Sistema não boota de jeito nenhum | Método 2 (manual / live USB)  |

---

## Comandos úteis

```bash
snapper -c root list        # snapshots da raiz
snapper -c home list        # snapshots do home
sudo btrfs subvolume list / # lista todos os subvolumes
lsblk -f                    # identifica o device correto
```

> Fonte do método manual (adaptada do layout CachyOS `root` para o `@` daqui):
> https://discuss.cachyos.org/t/how-to-restore-a-snapper-root-snapshot-on-an-unbootable-system/5007
