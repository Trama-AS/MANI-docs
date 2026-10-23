# ADR-0013 — Almacenamiento de documentos KYC

- **Estado:** Propuesto
- **Decisión de:** almacenamiento y seguridad
- **Relacionado con:** REST-02, RF-05, RF-06, ADR-0012

## Contexto

Los documentos KYC deben quedar aislados entre tenants y entre aliados del mismo tenant.

## Alternativas

1. **Bucket por tenant.** Descartada por sobrecarga de administración.
2. **Autorización solo en backend.** Descartada por depender de una única barrera.
3. **Bucket privado único + ruta segregada + políticas de acceso.** Elegida.

## Decisión

Los documentos KYC se almacenan en un bucket privado de Supabase Storage con la convención:

`tenant_id/aliado_id/documento`

El acceso se controla mediante políticas que validan tenant y aliado.

## Justificación

Mantiene un único recurso de almacenamiento y conserva aislamiento lógico verificable.

## Consecuencias

### Positivas
- Escala sin crear buckets por tenant.
- Política centralizada.

### Negativas
- La construcción correcta de la ruta forma parte del control de seguridad.

## Condición de revisión

Revisar si requisitos regulatorios exigen segregación física del almacenamiento.
